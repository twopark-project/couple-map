package com.couplemap.login.service;

import com.couplemap.global.exception.code.LoginErrorCode;
import com.couplemap.global.exception.exceptions.LoginException;
import com.couplemap.global.util.FriendCodeGenerator;
import com.couplemap.jwt.dto.LoginTokenResponseDto;
import com.couplemap.jwt.service.AuthTokenService;
import com.couplemap.login.dto.GoogleResponse;
import com.couplemap.login.dto.KakaoResponse;
import com.couplemap.login.dto.NaverResponse;
import com.couplemap.login.dto.OAuth2Response;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

import static com.couplemap.global.exception.code.LoginErrorCode.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class LoginServiceImpl implements LoginService {

    private final UserRepository userRepository;
    private final FriendCodeGenerator codeGenerator;
    private final AuthTokenService authTokenService;
    private final RestTemplate restTemplate;

    @Value("${spring.security.oauth2.client.provider.kakao.user-info-uri}")
    private String kakaoUserInfoUri;

    @Value("${spring.security.oauth2.client.provider.naver.user-info-uri}")
    private String naverUserInfoUri;

    @Value("${spring.security.oauth2.client.provider.google.user-info-uri}")
    private String googleUserInfoUri;

    @Override
    @Transactional
    public LoginTokenResponseDto socialLogin(String provider, String accessToken) {
        // 1. 사용자 정보 요청
        Map<String, Object> userAttributes = getUserAttributes(provider, accessToken);

        // 2. 사용자 정보 바탕으로 OAuth2Response 객체 생성
        OAuth2Response oAuth2Response = getOAuth2Response(provider, userAttributes);

        // 3. 사용자 확인 및 생성
        User user = getUser(oAuth2Response, provider);

        // 4. 토큰 생성 (닉네임 설정 여부 포함)
        boolean isNicknameSet = user.hasNickname();
        return authTokenService.generateTokens(user.getUserId(), user.getName(), user.getRole().name(), isNicknameSet);
    }

    private Map<String, Object> getUserAttributes(String provider, String accessToken) {
        String userInfoUri = null;
        if ("kakao".equalsIgnoreCase(provider)) {
            userInfoUri = kakaoUserInfoUri;
        } else if ("naver".equalsIgnoreCase(provider)) {
            userInfoUri = naverUserInfoUri;
        } else if ("google".equalsIgnoreCase(provider)) {
            userInfoUri = googleUserInfoUri;
        } else {
            throw new LoginException(LoginErrorCode.UNSUPPORTED_SOCIAL_LOGIN);
        }

        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(headers);

        try {
            ResponseEntity<Map> response = restTemplate.exchange(userInfoUri, HttpMethod.GET, request, Map.class);
            log.debug("소셜 로그인 사용자 정보 조회 완료: provider={}", provider);
            return response.getBody();
        } catch (HttpClientErrorException e) {
            log.warn("소셜 로그인 실패(클라이언트 오류): provider={}, status={}", provider, e.getStatusCode());
            throw new LoginException(INVALID_ACCESS_TOKEN);
        } catch (HttpServerErrorException e) {
            log.error("소셜 로그인 실패(제공자 서버 오류): provider={}, status={}", provider, e.getStatusCode());
            throw new LoginException(SOCIAL_PROVIDER_ERROR);
        } catch (ResourceAccessException e) {
            log.error("소셜 로그인 실패(네트워크 오류): provider={}", provider, e);
            throw new LoginException(SOCIAL_PROVIDER_UNAVAILABLE);
        }
    }

    private OAuth2Response getOAuth2Response(String provider, Map<String, Object> userAttributes) {
        if ("kakao".equalsIgnoreCase(provider)) {
            return new KakaoResponse(userAttributes);
        } else if ("naver".equalsIgnoreCase(provider)) {
            return new NaverResponse(userAttributes);
        } else if ("google".equalsIgnoreCase(provider)) {
            return new GoogleResponse(userAttributes);
        }
        return null;
    }

    private User getUser(OAuth2Response oAuth2Response, String provider) {
        String providerId = oAuth2Response.getProvider() + "_" + oAuth2Response.getProviderId();
        User existData = userRepository.findByProviderId(providerId);

        if (existData == null) {
            String friendCode = codeGenerator.generateCode();
            User newUser = User.builder()
                    .loginType(oAuth2Response.getProvider())
                    .providerId(providerId)
                    .email(oAuth2Response.getEmail())
                    .name(oAuth2Response.getName())
                    .role(UserRole.USER)
                    .friendCode(friendCode)
                    .build();
            return userRepository.save(newUser);
        } else {
            existData.updateProfile(oAuth2Response.getName(), oAuth2Response.getEmail());
            return userRepository.save(existData);
        }
    }
}

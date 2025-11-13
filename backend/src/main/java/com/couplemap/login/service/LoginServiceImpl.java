package com.couplemap.login.service;

import com.couplemap.global.util.FriendCodeGenerator;
import com.couplemap.jwt.dto.TokenResponseDto;
import com.couplemap.jwt.service.AuthTokenService;
import com.couplemap.login.dto.GoogleResponse;
import com.couplemap.login.dto.KakaoResponse;
import com.couplemap.login.dto.NaverResponse;
import com.couplemap.login.dto.OAuth2Response;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class LoginServiceImpl implements LoginService {

    private final UserRepository userRepository;
    private final FriendCodeGenerator codeGenerator;
    private final AuthTokenService authTokenService;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${spring.security.oauth2.client.provider.kakao.user-info-uri}")
    private String kakaoUserInfoUri;

    @Value("${spring.security.oauth2.client.provider.naver.user-info-uri}")
    private String naverUserInfoUri;

    @Value("${spring.security.oauth2.client.provider.google.user-info-uri}")
    private String googleUserInfoUri;

    @Override
    public TokenResponseDto socialLogin(String provider, String accessToken) {
        // 1. 사용자 정보 요청
        Map<String, Object> userAttributes = getUserAttributes(provider, accessToken);

        // 2. 사용자 정보 바탕으로 OAuth2Response 객체 생성
        OAuth2Response oAuth2Response = getOAuth2Response(provider, userAttributes);
        if (oAuth2Response == null) {
            throw new IllegalArgumentException("지원하지 않는 소셜 로그인입니다.");
        }

        // 3. 사용자 확인 및 생성
        User user = getUser(oAuth2Response, provider);

        // 4. 토큰 생성
        return authTokenService.generateTokens(user.getUserId(), user.getName(), user.getRole().name());
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
            throw new IllegalArgumentException("지원하지 않는 소셜 로그인입니다.");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(headers);
        ResponseEntity<Map> response = restTemplate.exchange(userInfoUri, HttpMethod.GET, request, Map.class);

        return response.getBody();
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
                    .loginType(provider)
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

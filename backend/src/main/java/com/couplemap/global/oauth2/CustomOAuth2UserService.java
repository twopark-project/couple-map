package com.couplemap.global.oauth2;

import com.couplemap.global.util.FriendCodeGenerator;
import com.couplemap.login.dto.*;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    private final UserRepository userRepository;
    private final FriendCodeGenerator codeGenerator;


    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {

        OAuth2User oAuth2User = super.loadUser(userRequest);

        log.info("OAuth2 user loaded: {}", oAuth2User);

        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        OAuth2Response oAuth2Response = null;
        if (registrationId.equals("naver")) {
            oAuth2Response = new NaverResponse(oAuth2User.getAttributes());
        }
//         else if (registrationId.equals("google")) {
//
//            oAuth2Response = new GoogleResponse(oAuth2User.getAttributes());
//        }//
        else if (registrationId.equals("kakao")) {

            oAuth2Response = new KakaoResponse(oAuth2User.getAttributes());
        }
        else {
            return null;
        }

        String providerId = oAuth2Response.getProvider() + "_" + oAuth2Response.getProviderId();
        User existData = userRepository.findByProviderId(providerId);

        String email = oAuth2Response.getEmail();
        String name = oAuth2Response.getName();

        if (existData == null) {

            String friendCode = codeGenerator.generateCode();
            User user = new User(registrationId, providerId, email, name, UserRole.USER, friendCode);
            userRepository.save(user);
            UserDTO userDTO = UserDTO.builder()
                    .userId(user.getUserId())
                    .username(name)
                    .role(UserRole.USER)
                    .oauthId(providerId).
                    build();

            return new CustomOAuth2User(userDTO);
        } else {
            existData.updateProfile(name,email);
            userRepository.save(existData);

            UserDTO userDTO = UserDTO.builder()
                    .userId(existData.getUserId())
                    .username(name)
                    .role(UserRole.USER)
                    .oauthId(providerId).
                    build();

            return new CustomOAuth2User(userDTO);
        }
    }
}
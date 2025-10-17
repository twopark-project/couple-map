package com.couplemap.login.service;

import com.couplemap.login.dto.*;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    private final UserRepository userRepository;

    public CustomOAuth2UserService(UserRepository userRepository) {

        this.userRepository = userRepository;
    }
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

        String providerId = oAuth2Response.getProvider() + " " + oAuth2Response.getProviderId();
        User existData = userRepository.findByProviderId(providerId);

        String email = oAuth2Response.getEmail();
        String name = oAuth2Response.getName();

        if (existData == null) {

            User user = new User(registrationId,providerId,email,name,UserRole.USER);
            userRepository.save(user);

            UserDTO userDTO = new UserDTO();
            userDTO.setUsername(providerId);
            userDTO.setName(oAuth2Response.getName());
            userDTO.setRole(UserRole.USER);

            return new CustomOAuth2User(userDTO);
        } else {
            existData.updateProfile(name,email);
            userRepository.save(existData);

            UserDTO userDTO = new UserDTO();
            userDTO.setUsername(existData.getProviderId());
            userDTO.setName(oAuth2Response.getName());
            userDTO.setRole(existData.getRole());

            return new CustomOAuth2User(userDTO);
        }
    }
}
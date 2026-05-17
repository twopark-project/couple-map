package com.couplemap.login.dto;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;
import java.util.Objects;

@RequiredArgsConstructor
public class CustomOAuth2User implements OAuth2User {
    private final UserDTO userDTO;


    @Override
    public Map<String, Object> getAttributes() {
        return Map.of();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        Collection<GrantedAuthority> collection = new ArrayList<>();
        collection.add(new GrantedAuthority() {
            @Override
            public String getAuthority() {
                return userDTO.getRole().name();
            }
        });
        return collection;
    }

    @Override
    public String getName() {
        return Objects.requireNonNull(userDTO.getUserId(), "userId는 null일 수 없습니다.").toString();
    }

    public Long getUserId() { return userDTO.getUserId();}

    public String getUsername(){
        return userDTO.getUsername();
    }
}

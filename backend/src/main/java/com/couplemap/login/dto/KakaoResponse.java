package com.couplemap.login.dto;

import java.util.Map;

public class KakaoResponse implements OAuth2Response{

    private final Map<String, Object> attribute;

    public KakaoResponse(Map<String, Object> attribute) {
        this.attribute = attribute;
    }

    @Override
    public String getProvider() {
        return "kakao";
    }

    @Override
    public String getProviderId() {
        Object id = attribute.get("id");
           if (id == null) {
                    throw new IllegalStateException("Kakao response missing required 'id' field");
            }
        return id.toString();
    }

    @Override
    public String getEmail() {
        Object accountObj = attribute.get("kakao_account");
        if (accountObj == null || !(accountObj instanceof Map)) {
            throw new IllegalStateException("Kakao response missing or invalid 'kakao_account' field");
        }
        Map<String, Object> account = (Map<String, Object>) accountObj;
        Object email = account.get("email");
        if (email == null) {
            throw new IllegalStateException("Kakao account missing required 'email' field");
        }
        return email.toString();
    }

    @Override
    public String getName() {
        Object accountObj = attribute.get("kakao_account");
        if (accountObj == null || !(accountObj instanceof Map)) {
            throw new IllegalStateException("Kakao response missing or invalid 'kakao_account' field");
            }
        Map<String, Object> account = (Map<String, Object>) accountObj;
        Object profileObj = account.get("profile");
        if (profileObj == null || !(profileObj instanceof Map)) {
            throw new IllegalStateException("Kakao account missing or invalid 'profile' field");
        }
        Map<String, Object> profile = (Map<String, Object>) profileObj;
        Object nickname = profile.get("nickname");
        if (nickname == null) {
            throw new IllegalStateException("Kakao profile missing required 'nickname' field");
        }
        return nickname.toString();
    }
}

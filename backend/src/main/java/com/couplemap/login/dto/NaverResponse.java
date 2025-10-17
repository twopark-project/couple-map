package com.couplemap.login.dto;

import java.util.Map;

public class NaverResponse implements OAuth2Response{

    private final Map<String, Object> attribute;

    public NaverResponse(Map<String, Object> attribute) {
        Object response = attribute.get("response");
        if (response == null) {
            throw new IllegalArgumentException("Naver response does not contain 'response' key");
        }
        if (!(response instanceof Map)) {
            throw new IllegalArgumentException("Naver 'response' value is not a Map");
        }
        this.attribute = (Map<String, Object>) response;
    }

    @Override
    public String getProvider() {

        return "naver";
    }

    @Override
    public String getProviderId() {
        Object id = attribute.get("id");
        if (id == null) {
            throw new IllegalStateException("Naver response missing required 'id' field");
        }
        return id.toString();

    }

    @Override
    public String getEmail() {
        Object email = attribute.get("email");
        if (email == null) {
            throw new IllegalStateException("Naver response missing required 'email' field");
        }
        return email.toString();

    }

    @Override
    public String getName() {
        Object name = attribute.get("name");
        if (name == null) {
            throw new IllegalStateException("Naver response missing required 'name' field");
        }
        return name.toString();
    }
}
package com.couplemap.login.dto;

import java.util.Map;

public class GoogleResponse implements OAuth2Response {

    private final Map<String, Object> attribute;

    public GoogleResponse(Map<String, Object> attribute) {
        this.attribute = attribute;
    }

    @Override
    public String getProvider() {
        return "google";
    }

    @Override
    public String getProviderId() {
        Object sub = attribute.get("sub");
        if (sub == null) {
            throw new IllegalStateException("Google response missing required 'sub' field");
        }
        return sub.toString();
    }

    @Override
    public String getEmail() {
        Object email = attribute.get("email");
        if (email == null) {
            throw new IllegalStateException("Google response missing required 'email' field");
        }
        return email.toString();
    }

    @Override
    public String getName() {
        Object name = attribute.get("name");
        if (name == null) {
            throw new IllegalStateException("Google response missing required 'name' field");
        }
        return name.toString();
    }
}
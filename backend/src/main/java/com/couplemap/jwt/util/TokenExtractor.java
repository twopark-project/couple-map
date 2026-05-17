package com.couplemap.jwt.util;

import com.couplemap.global.exception.exceptions.JwtException;
import org.springframework.stereotype.Component;

import static com.couplemap.global.exception.code.JwtErrorCode.JWT_INVALID_FORMAT;
import static com.couplemap.global.exception.code.JwtErrorCode.JWT_TOKEN_NOT_FOUND;

@Component
public class TokenExtractor {

    private static final String BEARER_PREFIX = "Bearer ";

    public String extractToken(String authHeader) {

        if (authHeader == null || authHeader.isBlank()) {
            throw new JwtException(JWT_TOKEN_NOT_FOUND);
        }

        if (!authHeader.startsWith(BEARER_PREFIX)) {
            throw new JwtException(JWT_INVALID_FORMAT);
        }

        String token = authHeader.substring(BEARER_PREFIX.length());

        if (token.isBlank()) {
            throw new JwtException(JWT_TOKEN_NOT_FOUND);
        }
        return token;
    }
}

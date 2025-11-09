package com.couplemap.jwt.service;

import com.couplemap.jwt.dto.TokenResponseDto;

public interface AuthTokenService {
    TokenResponseDto generateTokens(Long userId, String username, String role);
    TokenResponseDto refreshTokens(String refreshToken);
    void logout(Long userId);
}

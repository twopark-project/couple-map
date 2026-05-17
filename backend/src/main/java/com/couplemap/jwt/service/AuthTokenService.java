package com.couplemap.jwt.service;

import com.couplemap.jwt.dto.LoginTokenResponseDto;
import com.couplemap.jwt.dto.TokenResponseDto;

public interface AuthTokenService {
    LoginTokenResponseDto generateTokens(Long userId, String username, String role, boolean isNicknameSet);
    TokenResponseDto refreshTokens(String refreshToken);
    void logout(Long userId);
}

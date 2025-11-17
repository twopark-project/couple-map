package com.couplemap.login.service;

import com.couplemap.jwt.dto.TokenResponseDto;

public interface LoginService {
    TokenResponseDto socialLogin(String provider, String accessToken);
}

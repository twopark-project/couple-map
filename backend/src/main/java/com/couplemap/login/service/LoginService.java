package com.couplemap.login.service;

import com.couplemap.jwt.dto.LoginTokenResponseDto;

public interface LoginService {
    LoginTokenResponseDto socialLogin(String provider, String accessToken);
}

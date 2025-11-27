package com.couplemap.jwt.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class LoginTokenResponseDto {
    private final String accessToken;
    private final String refreshToken;
    private final Long expiresIn;
    private final boolean isNicknameSet;
}

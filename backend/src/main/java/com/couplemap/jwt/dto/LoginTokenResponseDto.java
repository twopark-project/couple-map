package com.couplemap.jwt.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class LoginTokenResponseDto {
    private final String accessToken;
    private final String refreshToken;
    private final Long expiresIn;

    @JsonProperty("isNicknㅇameSet")
    private final boolean isNicknameSet;
}

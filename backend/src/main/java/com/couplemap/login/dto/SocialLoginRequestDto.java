package com.couplemap.login.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class SocialLoginRequestDto {
    @NotBlank(message = "소셜 access token은 필수입니다.")
    private String accessToken;
}

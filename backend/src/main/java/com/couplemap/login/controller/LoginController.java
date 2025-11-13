package com.couplemap.login.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.jwt.dto.TokenResponseDto;
import com.couplemap.login.dto.SocialLoginRequestDto;
import com.couplemap.login.service.LoginService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/login")
public class LoginController {

    private final LoginService loginService;

    @PostMapping("/oauth2/{provider}")
    public ResponseEntity<ApiResponse<TokenResponseDto>> socialLogin(
            @PathVariable String provider,
            @RequestBody SocialLoginRequestDto request) {
        TokenResponseDto tokenResponseDto = loginService.socialLogin(provider, request.getAccessToken());
        return ResponseEntity.ok(ApiResponse.success(tokenResponseDto, "소셜 로그인이 완료되었습니다."));
    }
}

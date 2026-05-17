package com.couplemap.jwt.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.jwt.dto.TokenResponseDto;
import com.couplemap.jwt.service.AuthTokenService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@Tag(name = "Auth", description = "인증 관리 API - 토큰 재발급 및 로그아웃")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthTokenService authTokenService;

    @SecurityRequirement(name = "Refresh Token (Bearer)")
    @Operation(summary = "토큰 재발급", description = "Refresh Token을 사용하여 새로운 Access Token을 발급받습니다")
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenResponseDto>> refreshToken(
            @RequestHeader("Authorization") String authHeader) {

        TokenResponseDto response = authTokenService.refreshTokens(authHeader);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @Operation(summary = "로그아웃", description = "로그아웃 처리 및 Refresh Token을 무효화합니다")
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<String>> logout(
            @AuthenticationPrincipal(expression = "userId") Long userId) {

        authTokenService.logout(userId);

        return ResponseEntity.ok(ApiResponse.success("로그아웃되었습니다."));
    }
}
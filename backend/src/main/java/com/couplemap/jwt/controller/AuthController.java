package com.couplemap.jwt.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.jwt.dto.TokenResponseDto;
import com.couplemap.jwt.service.AuthTokenService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthTokenService authTokenService;

    /**
     * 토큰 재발급 API
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenResponseDto>> refreshToken(
            @RequestHeader("Authorization") String authHeader) {

        TokenResponseDto response = authTokenService.refreshTokens(authHeader);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 로그아웃 API
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<String>> logout(
            @AuthenticationPrincipal(expression = "userId") Long userId) {

        authTokenService.logout(userId);

        return ResponseEntity.ok(ApiResponse.success("로그아웃되었습니다."));
    }
}
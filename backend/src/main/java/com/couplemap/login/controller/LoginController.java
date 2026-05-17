package com.couplemap.login.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.jwt.dto.LoginTokenResponseDto;
import com.couplemap.login.dto.SocialLoginRequestDto;
import com.couplemap.login.service.LoginService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Login", description = "로그인 관리 API")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/login")
public class LoginController {

    private final LoginService loginService;

    @Operation(
        summary = "소셜 로그인",
        description = "OAuth2 소셜 로그인을 수행합니다. provider는 kakao, naver, google 중 하나입니다. " +
                      "응답의 isNicknameSet이 false인 경우 닉네임 설정 페이지로 이동해야 합니다."
    )
    @PostMapping("/social/{provider}")
    public ResponseEntity<ApiResponse<LoginTokenResponseDto>> socialLogin(
            @PathVariable String provider,
            @Valid @RequestBody SocialLoginRequestDto request) {
        LoginTokenResponseDto logintokenResponseDto = loginService.socialLogin(provider, request.getAccessToken());
        return ResponseEntity.ok(ApiResponse.success(logintokenResponseDto, "소셜 로그인이 완료되었습니다."));
    }
}

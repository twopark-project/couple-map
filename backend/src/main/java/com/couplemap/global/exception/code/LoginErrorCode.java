package com.couplemap.global.exception.code;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum LoginErrorCode implements ErrorCode {

    UNSUPPORTED_SOCIAL_LOGIN(HttpStatus.BAD_REQUEST, "지원하지 않는 소셜 로그인입니다."),
    INVALID_ACCESS_TOKEN(HttpStatus.UNAUTHORIZED, "유효하지 않은 소셜 로그인 토큰입니다."),
    LOGIN_PROVIDER_MISMATCH(HttpStatus.CONFLICT, "다른 소셜 계정으로 이미 가입된 이메일입니다."),
    SOCIAL_PROVIDER_ERROR(HttpStatus.BAD_GATEWAY, "소셜 로그인 제공자 서버에서 오류가 발생했습니다."),
    SOCIAL_PROVIDER_UNAVAILABLE(HttpStatus.SERVICE_UNAVAILABLE, "소셜 로그인 제공자에 연결할 수 없습니다.");

    private final HttpStatus httpStatus;
    private final String message;

    @Override
    public String getCodeName() {
        return this.name();
    }
}

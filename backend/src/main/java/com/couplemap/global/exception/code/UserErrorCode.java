package com.couplemap.global.exception.code;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

import static org.springframework.http.HttpStatus.*;

@Getter
@RequiredArgsConstructor
public enum UserErrorCode implements ErrorCode {
    USER_NOT_FOUND(NOT_FOUND, "사용자를 찾을 수 없습니다."),
    DUPLICATE_NICKNAME(CONFLICT, "이미 사용 중인 닉네임입니다.");

    private final HttpStatus httpStatus;
    private final String message;

    @Override
    public String getCodeName() {
        return this.name();
    }

}

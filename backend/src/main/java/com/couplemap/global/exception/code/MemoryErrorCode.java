package com.couplemap.global.exception.code;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum MemoryErrorCode implements ErrorCode {

    MEMORY_NOT_FOUND(HttpStatus.NOT_FOUND, "존재하지 않는 추억입니다.");

    private final HttpStatus httpStatus;
    private final String message;

    @Override
    public String getCodeName() {
        return this.name();
    }
}

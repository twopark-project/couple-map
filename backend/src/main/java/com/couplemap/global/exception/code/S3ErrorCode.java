package com.couplemap.global.exception.code;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR;

@RequiredArgsConstructor
@Getter
public enum S3ErrorCode implements ErrorCode {
    // 파일 관련
    FILE_IS_EMPTY(BAD_REQUEST, "파일이 비어있습니다."),
    FILE_SIZE_EXCEEDED(BAD_REQUEST, "파일 크기는 5MB를 초과할 수 없습니다."),
    INVALID_FILE_TYPE(BAD_REQUEST, "JPG, JPEG, PNG 파일만 업로드 가능합니다."),
    INVALID_FILE_NAME(BAD_REQUEST, "올바른 파일명이 아닙니다."),
    INVALID_FILE_EXTENSION(BAD_REQUEST, "파일 확장자가 올바르지 않습니다."),


    // S3 관련
    S3_UPLOAD_FAILED(INTERNAL_SERVER_ERROR, "S3 파일 업로드에 실패했습니다."),
    S3_DELETE_FAILED(INTERNAL_SERVER_ERROR, "S3 파일 삭제에 실패했습니다.");

    private final HttpStatus httpStatus;
    private final String message;

    @Override
    public String getCodeName() {
        return this.name();
    }
}

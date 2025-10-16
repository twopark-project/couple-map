package com.couplemap.global.exception;

import com.couplemap.global.exception.exceptions.BaseException;
import com.couplemap.global.response.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BaseException.class)
    public ResponseEntity<ApiResponse<Void>> handleBaseException(BaseException e) {
        log.error("BaseException: {} - {}", e.getCode().getCodeName(), e.getMessage(), e);
        return ResponseEntity
                .status(e.getCode().getHttpStatus())
                .body(ApiResponse.fail(e.getCode()));
    }


}

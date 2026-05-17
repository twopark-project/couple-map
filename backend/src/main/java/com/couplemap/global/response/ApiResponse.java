package com.couplemap.global.response;

import com.couplemap.global.exception.code.ErrorCode;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;

@Getter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private final boolean success;
    private final String code;
    private final String message;
    private final T data;

    private ApiResponse(boolean success, String code, String message, T data) {
        this.success = success;
        this.code = code;
        this.message = message;
        this.data = data;
    }

    // 데이터만
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, null, null, data);
    }

    // 메시지만
    public static <T> ApiResponse<T> success(String message) {
        return new ApiResponse<>(true, null, message, null);
    }

    // 데이터 + 메시지
    public static <T> ApiResponse<T> success(T data, String message) {
        return new ApiResponse<>(true, null, message, data);
    }

    public static <T> ApiResponse<T> fail(ErrorCode errorCode) {
        return new ApiResponse<>(
                false,
                errorCode.getCodeName(),
                errorCode.getMessage(),
                null
        );
    }

    public static <T> ApiResponse<T> fail(ErrorCode errorCode, T data) {
        return new ApiResponse<>(
                false,
                errorCode.getCodeName(),
                errorCode.getMessage(),
                data
        );
    }
}

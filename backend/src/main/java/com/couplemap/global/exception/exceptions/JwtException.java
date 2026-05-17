package com.couplemap.global.exception.exceptions;

import com.couplemap.global.exception.code.ErrorCode;

public class JwtException extends BaseException {

    public JwtException(ErrorCode code) {
        super(code);
    }
}

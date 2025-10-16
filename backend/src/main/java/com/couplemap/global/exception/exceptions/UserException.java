package com.couplemap.global.exception.exceptions;

import com.couplemap.global.exception.code.ErrorCode;

public class UserException extends BaseException {
    public UserException(ErrorCode code) {
        super(code);
    }
}

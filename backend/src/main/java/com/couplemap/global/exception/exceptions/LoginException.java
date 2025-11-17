package com.couplemap.global.exception.exceptions;

import com.couplemap.global.exception.code.ErrorCode;

public class LoginException extends BaseException {
    public LoginException(ErrorCode code) {
        super(code);
    }
}

package com.couplemap.global.exception.exceptions;

import com.couplemap.global.exception.code.ErrorCode;

public class MemoryException extends BaseException {
    public MemoryException(ErrorCode code) {
        super(code);
    }
}

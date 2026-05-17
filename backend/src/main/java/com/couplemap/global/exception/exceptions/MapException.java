package com.couplemap.global.exception.exceptions;

import com.couplemap.global.exception.code.ErrorCode;

public class MapException extends BaseException {
    public MapException(ErrorCode code) {
        super(code);
    }
}

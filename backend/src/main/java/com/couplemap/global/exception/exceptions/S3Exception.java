package com.couplemap.global.exception.exceptions;

import com.couplemap.global.exception.code.ErrorCode;

public class S3Exception extends BaseException {
    public S3Exception(ErrorCode code) {
        super(code);
    }
}

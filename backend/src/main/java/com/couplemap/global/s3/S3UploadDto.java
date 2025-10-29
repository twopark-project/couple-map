package com.couplemap.global.s3;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class S3UploadDto {
    private final String url;
    private final String key;
}

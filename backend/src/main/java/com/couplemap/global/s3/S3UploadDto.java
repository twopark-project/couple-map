package com.couplemap.global.s3;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class S3UploadDto {
    private String url;
    private String key;
}

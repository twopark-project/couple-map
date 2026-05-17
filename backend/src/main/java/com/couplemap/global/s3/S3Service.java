package com.couplemap.global.s3;

import org.springframework.web.multipart.MultipartFile;

public interface S3Service {
    S3UploadDto uploadImageFile(MultipartFile file);
    S3UploadDto uploadMediaFile(MultipartFile file);
    void deleteFile(String deleteKey);
}

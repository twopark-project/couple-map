package com.couplemap.global.s3;

import org.springframework.web.multipart.MultipartFile;

public interface S3Service {
    public S3UploadDto uploadImageFile(MultipartFile file);
    public void deleteFile(String deleteKey);
}

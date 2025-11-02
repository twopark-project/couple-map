package com.couplemap.global.s3;

import com.couplemap.global.exception.exceptions.S3Exception;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.util.Set;
import java.util.UUID;

import static com.couplemap.global.exception.code.S3ErrorCode.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class S3ServiceImpl implements S3Service {

    private static final String PROFILE_DIR = "profile";
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
            "image/jpeg",
            "image/jpg",
            "image/png"
    );
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(
            "jpeg",
            "jpg",
            "png"
    );

    private final S3Client s3Client;

    @Value("${spring.cloud.aws.s3.bucket}")
    private String bucket;
    @Value("${spring.cloud.aws.region.static}")
    private String region;

    public S3UploadDto uploadImageFile(MultipartFile file) {
        validateFile(file);
        String fileName = createFileName(file.getOriginalFilename(), PROFILE_DIR);

        try {
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucket)
                    .key(fileName)
                    .contentType(file.getContentType())
                    .build();

            s3Client.putObject(putObjectRequest,
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize()));

            String url = getFileUrl(fileName);

            return S3UploadDto.builder()
                    .url(url)
                    .key(fileName)
                    .build();

        } catch (Exception e) {
            log.error("S3 파일 업로드 실패: {}", e.getMessage());
            throw new S3Exception(S3_UPLOAD_FAILED);
        }
    }

    public void deleteFile(String deleteKey) {
        try {
            DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
                    .bucket(bucket)
                    .key(deleteKey)
                    .build();

            s3Client.deleteObject(deleteObjectRequest);
            log.info("S3 파일 삭제 성공: {}", deleteKey);
        } catch (Exception e) {
            log.error("S3 파일 삭제 실패: {}", e.getMessage());
            throw new S3Exception(S3_DELETE_FAILED);
        }
    }

    private String createFileName(String originalFileName, String dirName) {
        String ext = extractExt(originalFileName);
        String uuid = UUID.randomUUID().toString();
        return dirName + "/" + uuid + "." + ext;
    }

    private String extractExt(String originalFileName) {
        int pos = originalFileName.lastIndexOf(".");
        if (pos == -1) {
            throw new S3Exception(INVALID_FILE_EXTENSION);
        }
        String ext = originalFileName.substring(pos + 1).toLowerCase();

        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            log.warn("허용되지 않은 확장자: {}", ext);
            throw new S3Exception(INVALID_FILE_TYPE);
        }
        return ext;
    }

    private String getFileUrl(String fileName) {
        return String.format("https://%s.s3.%s.amazonaws.com/%s", bucket, region, fileName);
    }

    private void validateFile(MultipartFile file){
        checkNull(file);
        checkSize(file);
        checkContentType(file);
        checkFileExtension(file);
    }

    void checkNull(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new S3Exception(FILE_IS_EMPTY);
        }
    }

    void checkSize(MultipartFile file) {
        if (file.getSize() > MAX_FILE_SIZE) {
            log.error("파일 크기 초과: {}bytes (최대: {}bytes)", file.getSize(), MAX_FILE_SIZE);
            throw new S3Exception(FILE_SIZE_EXCEEDED);
        }
    }
    void checkContentType(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType)) {
            log.warn("허용되지 않은 Content-Type: {}", contentType);
            throw new S3Exception(INVALID_FILE_TYPE);
        }
    }

    void checkFileExtension(MultipartFile file) {
        String originalFilename = file.getOriginalFilename();

        if (originalFilename == null || originalFilename.isEmpty()) {
            throw new S3Exception(INVALID_FILE_NAME);
        }

        if (!originalFilename.contains(".")) {
            throw new S3Exception(INVALID_FILE_NAME);
        }

        extractExt(originalFilename);
    }

}
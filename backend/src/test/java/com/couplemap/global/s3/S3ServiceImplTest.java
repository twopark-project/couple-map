package com.couplemap.global.s3;

import com.couplemap.global.exception.exceptions.S3Exception;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class S3ServiceImplTest {

    @Autowired
    private S3ServiceImpl s3ServiceImpl;

    private List<String> uploadedKeys = new ArrayList<>();

    @AfterEach
    void cleanup() {
        // 테스트에서 업로드된 모든 파일 삭제
        for (String key : uploadedKeys) {
            try {
                s3ServiceImpl.deleteFile(key);
                System.out.println("정리 완료: " + key);
            } catch (Exception e) {
                System.out.println("정리 실패 (이미 삭제됨): " + key);
            }
        }
        uploadedKeys.clear();
    }


    @Test
    @DisplayName("실제 S3 파일 업로드 성공")
    void uploadImageFile_Success() throws IOException {
        File testFile = new File("src/test/resources/test.png");
        assertTrue(testFile.exists(), "테스트 이미지 파일이 존재하지 않습니다");

        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile validFile = new MockMultipartFile(
                "file", "test.png", "image/png", input
        );

        S3UploadDto result = s3ServiceImpl.uploadImageFile(validFile);

        assertThat(result.getUrl()).isNotNull();
        assertThat(result.getUrl()).contains("s3");
        assertThat(result.getUrl()).contains(".amazonaws.com");
        assertThat(result.getKey()).startsWith("profile/");
        assertThat(result.getKey()).endsWith(".png");

        uploadedKeys.add(result.getKey());
        System.out.println("업로드된 파일 URL: " + result.getUrl());
    }

    @Test
    @DisplayName("실제 S3 파일 삭제 성공")
    void deleteFile_Success() throws IOException {
        File testFile = new File("src/test/resources/test.png");
        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile file = new MockMultipartFile(
                "file", "test.png", "image/png", input
        );
        S3UploadDto uploaded = s3ServiceImpl.uploadImageFile(file);

        assertDoesNotThrow(() -> s3ServiceImpl.deleteFile(uploaded.getKey()));
        System.out.println("삭제 성공: " + uploaded.getKey());
    }


    @Test
    @DisplayName("여러 점이 있는 파일명 (my.photo.png) 정상 작동 확인")
    void checkFileExtension_MultipleDots() {
        MockMultipartFile multiDotFile = new MockMultipartFile(
                "file", "my.photo.png", "image/png", "content".getBytes()
        );

        assertDoesNotThrow(() -> s3ServiceImpl.checkFileExtension(multiDotFile));
    }

    @Test
    @DisplayName("빈 파일 예외")
    void uploadImageFile_EmptyFile() {
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file", "test.png", "image/png", new byte[0]
        );

        assertThrows(S3Exception.class,
                () -> s3ServiceImpl.checkNull(emptyFile));
    }

    @Test
    @DisplayName("파일 크기 초과 예외")
    void uploadImageFile_SizeExceeded() {
        byte[] bigContent = new byte[6 * 1024 * 1024]; // 6MB
        MockMultipartFile bigFile = new MockMultipartFile(
                "file", "big.png", "image/png", bigContent
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.checkSize(bigFile));

        assertThat(exception.getMessage()).isEqualTo("파일 크기는 5MB를 초과할 수 없습니다.");
    }

    @Test
    @DisplayName("잘못된 ContentType 예외")
    void uploadImageFile_InvalidContentType() {
        MockMultipartFile invalidFile = new MockMultipartFile(
                "file", "test.exe", "application/exe", "content".getBytes()
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.checkContentType(invalidFile));

        assertThat(exception.getMessage()).isEqualTo("JPG, JPEG, PNG 파일만 업로드 가능합니다.");
    }

    @Test
    @DisplayName("확장자 없는 파일명 예외")
    void uploadImageFile_NoExtension() {
        MockMultipartFile noExtFile = new MockMultipartFile(
                "file", "noextension", "image/png", "content".getBytes()
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.checkFileExtension(noExtFile));

        assertThat(exception.getMessage()).isEqualTo("올바른 파일명이 아닙니다.");
    }

    @Test
    @DisplayName("잘못된 확장자 예외")
    void uploadImageFile_InvalidExtension() {
        MockMultipartFile invalidExtFile = new MockMultipartFile(
                "file", "test.exe", "image/png", "content".getBytes()
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.checkFileExtension(invalidExtFile));

        assertThat(exception.getMessage()).isEqualTo("JPG, JPEG, PNG 파일만 업로드 가능합니다.");
    }

    @Test
    @DisplayName("jpg 파일 업로드 성공")
    void uploadImageFile_JpgSuccess() throws IOException {
        File testFile = new File("src/test/resources/test.png");
        if (!testFile.exists()) {
            return;
        }

        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile jpgFile = new MockMultipartFile(
                "file", "test.jpg", "image/jpeg", input
        );

        S3UploadDto result = s3ServiceImpl.uploadImageFile(jpgFile);

        assertThat(result.getUrl()).isNotNull();
        assertThat(result.getKey()).endsWith(".jpg");

        uploadedKeys.add(result.getKey());
    }

}
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
    }


    @Test
    @DisplayName("여러 점이 있는 파일명 (my.photo.png) 정상 작동 확인")
    void checkFileExtension_MultipleDots() throws IOException {
        File testFile = new File("src/test/resources/test.png");
        if (!testFile.exists()) {
            return;
        }

        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile multiDotFile = new MockMultipartFile(
                "file", "my.photo.png", "image/png", input
        );

        S3UploadDto result = assertDoesNotThrow(() -> s3ServiceImpl.uploadImageFile(multiDotFile));
        uploadedKeys.add(result.getKey());
    }

    @Test
    @DisplayName("빈 파일 예외")
    void uploadImageFile_EmptyFile() {
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file", "test.png", "image/png", new byte[0]
        );

        assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadImageFile(emptyFile));
    }

    @Test
    @DisplayName("파일 크기 초과 예외")
    void uploadImageFile_SizeExceeded() {
        byte[] bigContent = new byte[6 * 1024 * 1024]; // 6MB
        MockMultipartFile bigFile = new MockMultipartFile(
                "file", "big.png", "image/png", bigContent
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadImageFile(bigFile));

        assertThat(exception.getMessage()).isEqualTo("파일 크기는 5MB를 초과할 수 없습니다.");
    }

    @Test
    @DisplayName("잘못된 ContentType 예외")
    void uploadImageFile_InvalidContentType() {
        MockMultipartFile invalidFile = new MockMultipartFile(
                "file", "test.exe", "application/exe", "content".getBytes()
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadImageFile(invalidFile));

        assertThat(exception.getMessage()).isEqualTo("JPG, JPEG, PNG 파일만 업로드 가능합니다.");
    }

    @Test
    @DisplayName("확장자 없는 파일명 예외")
    void uploadImageFile_NoExtension() {
        MockMultipartFile noExtFile = new MockMultipartFile(
                "file", "noextension", "image/png", "content".getBytes()
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadImageFile(noExtFile));

        assertThat(exception.getMessage()).isEqualTo("올바른 파일명이 아닙니다.");
    }

    @Test
    @DisplayName("잘못된 확장자 예외")
    void uploadImageFile_InvalidExtension() {
        MockMultipartFile invalidExtFile = new MockMultipartFile(
                "file", "test.exe", "image/png", "content".getBytes()
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadImageFile(invalidExtFile));

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

    // ===================== uploadMediaFile 테스트 =====================

    @Test
    @DisplayName("mp3 오디오 파일 업로드 성공")
    void uploadMediaFile_Mp3Success() throws IOException {
        File testFile = new File("src/test/resources/test.mp3");
        if (!testFile.exists()) {
            return;
        }

        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile mp3File = new MockMultipartFile(
                "file", "test.mp3", "audio/mpeg", input
        );

        S3UploadDto result = s3ServiceImpl.uploadMediaFile(mp3File);

        assertThat(result.getUrl()).isNotNull();
        assertThat(result.getUrl()).contains(".amazonaws.com");
        assertThat(result.getKey()).startsWith("memory/");
        assertThat(result.getKey()).endsWith(".mp3");

        uploadedKeys.add(result.getKey());
    }

    @Test
    @DisplayName("m4a 오디오 파일 업로드 성공")
    void uploadMediaFile_M4aSuccess() throws IOException {
        File testFile = new File("src/test/resources/test.m4a");
        if (!testFile.exists()) {
            return;
        }

        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile m4aFile = new MockMultipartFile(
                "file", "test.m4a", "audio/x-m4a", input
        );

        S3UploadDto result = s3ServiceImpl.uploadMediaFile(m4aFile);

        assertThat(result.getUrl()).isNotNull();
        assertThat(result.getKey()).startsWith("memory/");
        assertThat(result.getKey()).endsWith(".m4a");

        uploadedKeys.add(result.getKey());
    }

    @Test
    @DisplayName("mp4 영상 파일 업로드 성공")
    void uploadMediaFile_Mp4Success() throws IOException {
        File testFile = new File("src/test/resources/test.mp4");
        if (!testFile.exists()) {
            return;
        }

        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile mp4File = new MockMultipartFile(
                "file", "test.mp4", "video/mp4", input
        );

        S3UploadDto result = s3ServiceImpl.uploadMediaFile(mp4File);

        assertThat(result.getUrl()).isNotNull();
        assertThat(result.getKey()).startsWith("memory/");
        assertThat(result.getKey()).endsWith(".mp4");

        uploadedKeys.add(result.getKey());
    }

    @Test
    @DisplayName("mov 영상 파일 업로드 성공")
    void uploadMediaFile_MovSuccess() throws IOException {
        File testFile = new File("src/test/resources/test.mov");
        if (!testFile.exists()) {
            return;
        }

        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile movFile = new MockMultipartFile(
                "file", "test.mov", "video/quicktime", input
        );

        S3UploadDto result = s3ServiceImpl.uploadMediaFile(movFile);

        assertThat(result.getUrl()).isNotNull();
        assertThat(result.getKey()).startsWith("memory/");
        assertThat(result.getKey()).endsWith(".mov");

        uploadedKeys.add(result.getKey());
    }

    @Test
    @DisplayName("미디어 파일 - 빈 파일 예외")
    void uploadMediaFile_EmptyFile() {
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file", "test.mp3", "audio/mpeg", new byte[0]
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadMediaFile(emptyFile));

        assertThat(exception.getMessage()).isEqualTo("파일이 비어있습니다.");
    }

    @Test
    @DisplayName("미디어 파일 - 100MB 크기 초과 예외")
    void uploadMediaFile_SizeExceeded() {
        byte[] bigContent = new byte[101 * 1024 * 1024]; // 101MB
        MockMultipartFile bigFile = new MockMultipartFile(
                "file", "big.mp4", "video/mp4", bigContent
        );

        assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadMediaFile(bigFile));
    }

    @Test
    @DisplayName("미디어 파일 - 허용되지 않은 ContentType 예외")
    void uploadMediaFile_InvalidContentType() {
        MockMultipartFile invalidFile = new MockMultipartFile(
                "file", "test.exe", "application/exe", "content".getBytes()
        );

        assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadMediaFile(invalidFile));
    }

    @Test
    @DisplayName("미디어 파일 - 확장자 없는 파일명 예외")
    void uploadMediaFile_NoExtension() {
        MockMultipartFile noExtFile = new MockMultipartFile(
                "file", "noextension", "audio/mpeg", "content".getBytes()
        );

        S3Exception exception = assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadMediaFile(noExtFile));

        assertThat(exception.getMessage()).isEqualTo("올바른 파일명이 아닙니다.");
    }

    @Test
    @DisplayName("미디어 파일 - 허용되지 않은 확장자 예외")
    void uploadMediaFile_InvalidExtension() {
        MockMultipartFile invalidExtFile = new MockMultipartFile(
                "file", "test.exe", "video/mp4", "content".getBytes()
        );

        assertThrows(S3Exception.class,
                () -> s3ServiceImpl.uploadMediaFile(invalidExtFile));
    }

    @Test
    @DisplayName("미디어 파일 - 이미지도 memory 디렉토리에 업로드 성공")
    void uploadMediaFile_ImageSuccess() throws IOException {
        File testFile = new File("src/test/resources/test.png");
        if (!testFile.exists()) {
            return;
        }

        FileInputStream input = new FileInputStream(testFile);
        MockMultipartFile pngFile = new MockMultipartFile(
                "file", "test.png", "image/png", input
        );

        S3UploadDto result = s3ServiceImpl.uploadMediaFile(pngFile);

        assertThat(result.getUrl()).isNotNull();
        assertThat(result.getKey()).startsWith("memory/");
        assertThat(result.getKey()).endsWith(".png");

        uploadedKeys.add(result.getKey());
    }

}
package com.couplemap.user.service;

import com.couplemap.global.s3.S3ServiceImpl;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.dto.ProfileImageResponseDto;
import com.couplemap.user.repository.UserRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
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

@SpringBootTest
class UserServiceImplTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private S3ServiceImpl s3ServiceImpl;

    private List<String> uploadedKeys = new ArrayList<>();
    private User testUser;
    private MockMultipartFile testFile1;
    private MockMultipartFile testFile2;

    @BeforeEach
    void setUp() throws IOException {
        // 테스트 유저 생성
        testUser = User.builder()
                .email("test@example.com")
                .name("테스트유저")
                .friendCode("TEST1234")
                .providerId("TEST12341")
                .loginType("KAKAO")
                .role(UserRole.USER)
                .build();
        testUser = userRepository.save(testUser);

        // 테스트 이미지 파일 2개 준비
        File file = new File("src/test/resources/test.png");

        FileInputStream input1 = new FileInputStream(file);
        testFile1 = new MockMultipartFile(
                "file", "first.png", "image/png", input1
        );

        FileInputStream input2 = new FileInputStream(file);
        testFile2 = new MockMultipartFile(
                "file", "second.png", "image/png", input2
        );
    }

    @AfterEach
    void cleanup() {
        // S3 파일 정리
        for (String key : uploadedKeys) {
            try {
                s3ServiceImpl.deleteFile(key);
            } catch (Exception e) {
            }
        }
        uploadedKeys.clear();

        // 테스트 유저 정리
        if (testUser != null) {
            try {
                userRepository.delete(testUser);
            } catch (Exception e) {
            }
        }
    }

    @Test
    @DisplayName("프로필 이미지 업로드 성공 - 실제 S3 업로드 및 DB 저장 확인")
    void updateProfileImage_Success() {
        ProfileImageResponseDto response = userService.updateProfileImage(testUser.getUserId(), testFile1);

        assertThat(response.getImageUrl()).isNotNull();
        assertThat(response.getImageUrl()).contains("s3");
        assertThat(response.getImageUrl()).contains(".amazonaws.com");

        User updatedUser = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(updatedUser.getProfileImageUrl()).isEqualTo(response.getImageUrl());
        assertThat(updatedUser.getProfileImageKey()).isNotNull();
        assertThat(updatedUser.getProfileImageKey()).startsWith("profile/");

        uploadedKeys.add(updatedUser.getProfileImageKey());
    }

    @Test
    @DisplayName("프로필 이미지 업데이트 - 기존 이미지 교체 및 DB 업데이트 확인")
    void updateProfileImage_Replace() {
        ProfileImageResponseDto firstResponse = userService.updateProfileImage(testUser.getUserId(), testFile1);
        String firstUrl = firstResponse.getImageUrl();
        String firstKey = userRepository.findById(testUser.getUserId()).orElseThrow().getProfileImageKey();

        ProfileImageResponseDto secondResponse = userService.updateProfileImage(testUser.getUserId(), testFile2);

        // 응답 검증 (URL이 달라야 함)
        assertThat(secondResponse.getImageUrl()).isNotNull();
        assertThat(secondResponse.getImageUrl()).isNotEqualTo(firstUrl);

        User updatedUser = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(updatedUser.getProfileImageUrl()).isEqualTo(secondResponse.getImageUrl());
        assertThat(updatedUser.getProfileImageKey()).isNotEqualTo(firstKey);
        assertThat(updatedUser.getProfileImageUrl()).isNotEqualTo(firstUrl);

        uploadedKeys.add(updatedUser.getProfileImageKey());
    }

    @Test
    @DisplayName("프로필 이미지 삭제 성공 - S3 및 DB에서 삭제 확인")
    void deleteProfileImage_Success() {
        ProfileImageResponseDto uploadResponse = userService.updateProfileImage(testUser.getUserId(), testFile1);
        String uploadedKey = userRepository.findById(testUser.getUserId()).orElseThrow().getProfileImageKey();

        System.out.println("업로드된 이미지 Key: " + uploadedKey);

        userService.deleteProfileImage(testUser.getUserId());

        User updatedUser = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(updatedUser.getProfileImageUrl()).isNull();
        assertThat(updatedUser.getProfileImageKey()).isNull();

    }

    @Test
    @DisplayName("프로필 이미지 삭제 - 이미지가 없는 경우에도 예외 발생 안 함")
    void deleteProfileImage_WhenNoImage() {
        User user = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(user.getProfileImageKey()).isNull();

        userService.deleteProfileImage(testUser.getUserId());

        User updatedUser = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(updatedUser.getProfileImageUrl()).isNull();
        assertThat(updatedUser.getProfileImageKey()).isNull();

    }

    @Test
    @DisplayName("프로필 이미지 삭제 후 재업로드 가능 확인")
    void deleteAndReuploadProfileImage() {
        ProfileImageResponseDto firstResponse = userService.updateProfileImage(testUser.getUserId(), testFile1);
        String firstKey = userRepository.findById(testUser.getUserId()).orElseThrow().getProfileImageKey();


        userService.deleteProfileImage(testUser.getUserId());

        User deletedUser = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(deletedUser.getProfileImageKey()).isNull();

        // 다시 업로드
        ProfileImageResponseDto secondResponse = userService.updateProfileImage(testUser.getUserId(), testFile2);
        String secondKey = userRepository.findById(testUser.getUserId()).orElseThrow().getProfileImageKey();

        assertThat(secondResponse.getImageUrl()).isNotNull();
        assertThat(secondKey).isNotNull();
        assertThat(secondKey).isNotEqualTo(firstKey);

        uploadedKeys.add(secondKey);
    }
}
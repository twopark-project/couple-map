package com.couplemap.jwt.util;

import com.couplemap.user.domain.UserRole;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.*;

class JWTUtilTest {

    private JWTUtil jwtUtil;
    private static final String TEST_SECRET = "testsecrettestsecrettestsecrettestsecret"; // 최소 32바이트

    @BeforeEach
    void setUp() {
        jwtUtil = new JWTUtil(TEST_SECRET);
    }

    @Test
    @DisplayName("JWT 토큰 생성 성공")
    void createJwt_Success() {
        // given
        String category = "access";
        String username = "test@test.com";
        String role = "USER";
        Long userId = 1L;
        Long expiredMs = 1000 * 60 * 30L; // 30분

        // when
        String token = jwtUtil.createJwt(category, username, role, userId, expiredMs);

        // then
        assertThat(token).isNotNull();
        assertThat(token).isNotEmpty();
    }

    @Test
    @DisplayName("JWT 토큰에서 username 추출")
    void getUsername_Success() {
        // given
        String expectedUsername = "test@test.com";
        String token = jwtUtil.createJwt("access", expectedUsername, "USER", 1L, 1000 * 60 * 30L);

        // when
        String actualUsername = jwtUtil.getUsername(token);

        // then
        assertThat(actualUsername).isEqualTo(expectedUsername);
    }

    @Test
    @DisplayName("JWT 토큰에서 userId 추출")
    void getUserId_Success() {
        // given
        Long expectedUserId = 123L;
        String token = jwtUtil.createJwt("access", "test@test.com", "USER", expectedUserId, 1000 * 60 * 30L);

        // when
        Long actualUserId = jwtUtil.getUserId(token);

        // then
        assertThat(actualUserId).isEqualTo(expectedUserId);
    }

    @Test
    @DisplayName("JWT 토큰에서 role 추출")
    void getRole_Success() {
        // given
        String token = jwtUtil.createJwt("access", "test@test.com", "USER", 1L, 1000 * 60 * 30L);

        // when
        UserRole role = jwtUtil.getRole(token);

        // then
        assertThat(role).isEqualTo(UserRole.USER);
    }

    @Test
    @DisplayName("JWT 토큰에서 category 추출")
    void getCategory_Success() {
        // given
        String expectedCategory = "access";
        String token = jwtUtil.createJwt(expectedCategory, "test@test.com", "USER", 1L, 1000 * 60 * 30L);

        // when
        String actualCategory = jwtUtil.getCategory(token);

        // then
        assertThat(actualCategory).isEqualTo(expectedCategory);
    }

    @Test
    @DisplayName("JWT 토큰 만료 확인 - 만료되지 않음")
    void isExpired_NotExpired() {
        // given
        String token = jwtUtil.createJwt("access", "test@test.com", "USER", 1L, 1000 * 60 * 30L); // 30분

        // when
        Boolean isExpired = jwtUtil.isExpired(token);

        // then
        assertThat(isExpired).isFalse();
    }

    @Test
    @DisplayName("JWT 토큰 만료 확인 - 만료됨")
    void isExpired_Expired() throws InterruptedException {
        // given
        String token = jwtUtil.createJwt("access", "test@test.com", "USER", 1L, 1L); // 1ms

        // when
        Thread.sleep(10); // 10ms 대기
        Boolean isExpired = jwtUtil.isExpired(token);

        // then
        assertThat(isExpired).isTrue();
    }

    @Test
    @DisplayName("ROLE_ 접두사가 있는 role도 정상 처리")
    void getRole_WithRolePrefix() {
        // given
        String token = jwtUtil.createJwt("access", "test@test.com", "ROLE_USER", 1L, 1000 * 60 * 30L);

        // when
        UserRole role = jwtUtil.getRole(token);

        // then
        assertThat(role).isEqualTo(UserRole.USER);
    }
}

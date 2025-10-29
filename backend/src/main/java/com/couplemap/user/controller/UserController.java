package com.couplemap.user.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.user.dto.ProfileImageResponse;
import com.couplemap.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
    프로필 이미지 업로드/수정
     */
    @PostMapping("/profile-image")
    public ResponseEntity<ApiResponse<ProfileImageResponse>> uploadProfileImage(
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal(expression = "userId") Long userId) {

        ProfileImageResponse response = userService.updateProfileImage(userId, file);

        return ResponseEntity.ok(ApiResponse.success(response, "프로필 사진 등록이 완료되었습니다."));
    }

    /**
     프로필 이미지 삭제
     */
    @DeleteMapping("/profile-image")
    public ResponseEntity<ApiResponse<Void>> deleteProfileImage(
            @AuthenticationPrincipal(expression = "userId") Long userId) {
        userService.deleteProfileImage(userId);
        return ResponseEntity.ok(ApiResponse.success("프로필 사진이 삭제되었습니다."));
    }
}
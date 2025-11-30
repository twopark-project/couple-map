package com.couplemap.user.service;

import com.couplemap.user.dto.ProfileImageResponseDto;
import com.couplemap.user.dto.NicknameResponseDto;
import com.couplemap.user.dto.UserInfoResponseDto;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {
    ProfileImageResponseDto updateProfileImage(Long userId, MultipartFile file);
    void deleteProfileImage(Long userId);
    NicknameResponseDto setNickname(Long userId, String nickname);
    UserInfoResponseDto getUserInfo(Long userId);
}

package com.couplemap.user.service;

import com.couplemap.user.dto.ProfileImageResponseDto;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {
    ProfileImageResponseDto updateProfileImage(Long userId, MultipartFile file);
    void deleteProfileImage(Long userId);
}

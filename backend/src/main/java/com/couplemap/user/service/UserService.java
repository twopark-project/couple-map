package com.couplemap.user.service;

import com.couplemap.user.dto.ProfileImageResponse;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {
    ProfileImageResponse updateProfileImage(Long userId, MultipartFile file);
    void deleteProfileImage(Long userId);
}

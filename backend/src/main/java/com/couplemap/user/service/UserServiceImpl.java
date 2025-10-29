package com.couplemap.user.service;

import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.global.s3.S3Service;
import com.couplemap.global.s3.S3UploadDto;
import com.couplemap.user.domain.User;
import com.couplemap.user.dto.ProfileImageResponse;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import static com.couplemap.global.exception.code.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final S3Service s3Service;

    @Transactional
    public ProfileImageResponse updateProfileImage(Long userId, MultipartFile file) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        // 프로필이 이미 있는 경우 -> 삭제 먼저
        if (user.getProfileImageKey() != null) {
            s3Service.deleteFile(user.getProfileImageKey());
        }

        S3UploadDto uploadResult = s3Service.uploadImageFile(file);

        user.updateProfileImage(uploadResult);

        return ProfileImageResponse.builder()
                .imageUrl(user.getProfileImageUrl())
                .build();
    }

    @Transactional
    public void deleteProfileImage(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));
        if (user.getProfileImageKey() == null) {
            return;
        }
        s3Service.deleteFile(user.getProfileImageKey());

        user.deleteProfileImage();
    }
}
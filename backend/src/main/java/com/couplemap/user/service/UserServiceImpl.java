package com.couplemap.user.service;

import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.global.s3.S3Service;
import com.couplemap.global.s3.S3UploadDto;
import com.couplemap.user.domain.User;
import com.couplemap.user.dto.ProfileImageResponseDto;
import com.couplemap.user.dto.NicknameResponseDto;
import com.couplemap.user.dto.UserInfoResponseDto;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

import static com.couplemap.global.exception.code.UserErrorCode.DUPLICATE_NICKNAME;
import static com.couplemap.global.exception.code.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final S3Service s3Service;

    @Transactional
    public ProfileImageResponseDto updateProfileImage(Long userId, MultipartFile file) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        String oldProfileImageKey = user.getProfileImageKey();
        S3UploadDto uploadResult = s3Service.uploadImageFile(file);
        if (oldProfileImageKey != null) {
            s3Service.deleteFile(oldProfileImageKey);
        }

        user.updateProfileImage(uploadResult);

        return ProfileImageResponseDto.builder()
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

    @Transactional
    public NicknameResponseDto setNickname(Long userId, String nickname) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        Optional<User> existingUser = userRepository.findByNickname(nickname);

        if (existingUser.isPresent() && !existingUser.get().getUserId().equals(userId)) {
            throw new UserException(DUPLICATE_NICKNAME);
        }
        
        user.updateNickname(nickname);
        
        return NicknameResponseDto.builder()
                .nickname(nickname)
                .build();
    }

    @Transactional(readOnly = true)
    public UserInfoResponseDto getUserInfo(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));
        
        return UserInfoResponseDto.from(user);
    }
}

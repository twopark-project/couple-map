package com.couplemap.user.service;

import com.couplemap.friend.repository.FriendshipRepository;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.global.s3.S3Service;
import com.couplemap.global.s3.S3UploadDto;
import com.couplemap.jwt.repository.RefreshTokenRepository;
import com.couplemap.map.domain.Map;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.user.domain.User;
import com.couplemap.user.dto.ProfileImageResponseDto;
import com.couplemap.user.dto.NicknameResponseDto;
import com.couplemap.user.dto.UserInfoResponseDto;
import com.couplemap.memory.repository.MemoryRepository;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

import static com.couplemap.global.exception.code.UserErrorCode.DUPLICATE_NICKNAME;
import static com.couplemap.global.exception.code.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final MemoryRepository memoryRepository;
    private final FriendshipRepository friendshipRepository;
    private final MapMemberRepository mapMemberRepository;
    private final MapRepository mapRepository;
    private final RefreshTokenRepository refreshTokenRepository;
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

        long memoryCount = memoryRepository.countByUserMaps(userId);
        return UserInfoResponseDto.from(user, memoryCount);
    }

    @Transactional
    public void deleteAccount(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        // 1. 유저가 작성한 추억 삭제
        memoryRepository.deleteAllByUser_UserId(userId);

        // 2. OWNER인 지도 → 해당 지도의 추억, 멤버, 지도 삭제
        List<Map> ownedMaps = mapMemberRepository.findOwnedMapsByUserId(userId);
        for (Map map : ownedMaps) {
            memoryRepository.deleteAllByMap_MapId(map.getMapId());
            mapMemberRepository.deleteAllByMap(map);
            if (map.getBackgroundKey() != null) {
                s3Service.deleteFile(map.getBackgroundKey());
            }
            mapRepository.delete(map);
        }

        // 3. 참여 중인 지도 멤버 삭제
        mapMemberRepository.deleteAllByUserId(userId);

        // 4. 친구 관계 삭제
        friendshipRepository.deleteAllByUserId(userId);

        // 5. 리프레시 토큰 삭제
        refreshTokenRepository.deleteById(String.valueOf(userId));

        // 6. 프로필 이미지 S3 삭제
        if (user.getProfileImageKey() != null) {
            s3Service.deleteFile(user.getProfileImageKey());
        }

        // 7. 유저 삭제
        userRepository.delete(user);
    }
}

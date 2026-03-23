package com.couplemap.user.service;

import com.couplemap.friend.domain.Friendship;
import com.couplemap.friend.domain.FriendshipStatus;
import com.couplemap.friend.repository.FriendshipRepository;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.global.s3.S3ServiceImpl;
import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.memory.domain.Memory;
import com.couplemap.memory.repository.MemoryRepository;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.dto.ProfileImageResponseDto;
import com.couplemap.user.dto.NicknameResponseDto;
import com.couplemap.user.dto.UserInfoResponseDto;
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
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
class UserServiceImplTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MapRepository mapRepository;

    @Autowired
    private MapMemberRepository mapMemberRepository;

    @Autowired
    private MemoryRepository memoryRepository;

    @Autowired
    private FriendshipRepository friendshipRepository;

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

    @Test
    @DisplayName("닉네임 설정 성공 - DB 저장 확인")
    void setNickname_Success() {
        // given
        String nickname = "커플맵유저";
        
        // 초기 상태 확인 (닉네임 없음)
        User beforeUser = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(beforeUser.getNickname()).isNull();
        assertThat(beforeUser.hasNickname()).isFalse();
        
        // when
        NicknameResponseDto response = userService.setNickname(testUser.getUserId(), nickname);
        
        // then
        assertThat(response.getNickname()).isEqualTo(nickname);
        
        User updatedUser = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(updatedUser.getNickname()).isEqualTo(nickname);
        assertThat(updatedUser.hasNickname()).isTrue();
    }

    @Test
    @DisplayName("닉네임 변경 성공 - 기존 닉네임에서 새로운 닉네임으로 업데이트")
    void updateNickname_Success() {
        // given
        String firstNickname = "첫번째닉네임";
        String secondNickname = "두번째닉네임";
        
        // 첫 번째 닉네임 설정
        userService.setNickname(testUser.getUserId(), firstNickname);
        User userWithFirstNickname = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(userWithFirstNickname.getNickname()).isEqualTo(firstNickname);
        
        // when - 두 번째 닉네임으로 변경
        NicknameResponseDto response = userService.setNickname(testUser.getUserId(), secondNickname);
        
        // then
        assertThat(response.getNickname()).isEqualTo(secondNickname);
        
        User updatedUser = userRepository.findById(testUser.getUserId()).orElseThrow();
        assertThat(updatedUser.getNickname()).isEqualTo(secondNickname);
        assertThat(updatedUser.getNickname()).isNotEqualTo(firstNickname);
    }

    @Test
    @DisplayName("사용자 정보 조회 성공 - 닉네임 포함")
    void getUserInfo_WithNickname() {
        // given
        String nickname = "테스트닉네임";
        userService.setNickname(testUser.getUserId(), nickname);
        
        // when
        UserInfoResponseDto response = userService.getUserInfo(testUser.getUserId());
        
        // then
        assertThat(response.getUserId()).isEqualTo(testUser.getUserId());
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.getName()).isEqualTo("테스트유저");
        assertThat(response.getNickname()).isEqualTo(nickname);
        assertThat(response.getFriendCode()).isEqualTo("TEST1234");
    }

    @Test
    @DisplayName("사용자 정보 조회 성공 - 닉네임 없는 경우")
    void getUserInfo_WithoutNickname() {
        // when
        UserInfoResponseDto response = userService.getUserInfo(testUser.getUserId());

        // then
        assertThat(response.getUserId()).isEqualTo(testUser.getUserId());
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.getName()).isEqualTo("테스트유저");
        assertThat(response.getNickname()).isNull();
        assertThat(response.getFriendCode()).isEqualTo("TEST1234");
    }

    @Test
    @DisplayName("회원 탈퇴 성공 - 유저, 지도, 추억, 친구 관계 모두 삭제")
    void deleteAccount_Success() {
        // given - 친구 유저 생성
        User friendUser = userRepository.save(User.builder()
                .email("friend@example.com")
                .name("친구유저")
                .friendCode("FRIEND01")
                .providerId("FRIEND01")
                .loginType("KAKAO")
                .role(UserRole.USER)
                .build());

        // 지도 생성 (testUser가 OWNER)
        Map ownedMap = mapRepository.save(Map.from("우리의 지도", "설명", "COUPLE"));

        // 지도 멤버 등록
        mapMemberRepository.save(MapMember.from(ownedMap, testUser, MapMemberRole.OWNER));
        mapMemberRepository.save(MapMember.from(ownedMap, friendUser, testUser, MapMemberRole.EDITOR));

        // 추억 생성
        memoryRepository.save(Memory.builder()
                .map(ownedMap)
                .user(testUser)
                .title("첫 데이트")
                .placeName("카페")
                .address("서울시 강남구")
                .memoryDate(LocalDate.of(2025, 1, 1))
                .latitude(new BigDecimal("37.12345678"))
                .longitude(new BigDecimal("127.12345678"))
                .category("CAFE")
                .build());

        // 친구 관계 생성
        friendshipRepository.save(Friendship.createRequest(testUser, friendUser));

        Long userId = testUser.getUserId();
        Long mapId = ownedMap.getMapId();

        // when
        userService.deleteAccount(userId);

        // then - 유저 삭제 확인
        assertThat(userRepository.findById(userId)).isEmpty();

        // 지도 삭제 확인
        assertThat(mapRepository.findById(mapId)).isEmpty();

        // 지도 멤버 삭제 확인
        assertThat(mapMemberRepository.findAllByUser(friendUser)
                .stream().filter(mm -> mm.getMap().getMapId().equals(mapId)).toList()).isEmpty();

        // 추억 삭제 확인
        assertThat(memoryRepository.findAllByMap_MapId(mapId)).isEmpty();

        // 친구 관계 삭제 확인
        assertThat(friendshipRepository.findFriendsWhereRequester(userId, FriendshipStatus.PENDING)).isEmpty();
        assertThat(friendshipRepository.findFriendsWhereReceiver(userId, FriendshipStatus.PENDING)).isEmpty();

        // cleanup - testUser는 이미 삭제됨
        testUser = null;
        userRepository.delete(friendUser);
    }

    @Test
    @DisplayName("회원 탈퇴 실패 - 존재하지 않는 유저")
    void deleteAccount_UserNotFound() {
        // given
        Long nonExistentUserId = 99999L;

        // when & then
        assertThatThrownBy(() -> userService.deleteAccount(nonExistentUserId))
                .isInstanceOf(UserException.class);
    }
}
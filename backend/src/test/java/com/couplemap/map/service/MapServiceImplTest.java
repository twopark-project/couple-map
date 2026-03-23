package com.couplemap.map.service;

import com.couplemap.friend.domain.FriendshipStatus;
import com.couplemap.friend.repository.FriendshipRepository;
import com.couplemap.global.exception.exceptions.MapException;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.global.s3.S3Service;
import com.couplemap.global.s3.S3UploadDto;
import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.dto.*;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.multipart.MultipartFile;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static com.couplemap.global.exception.code.MapErrorCode.*;
import static com.couplemap.global.exception.code.UserErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("MapServiceImpl 테스트")
public class MapServiceImplTest {

    @Mock
    private MapRepository mapRepository;

    @Mock
    private MapMemberRepository mapMemberRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private FriendshipRepository friendshipRepository;

    @Mock
    private S3Service s3Service;

    @InjectMocks
    private MapServiceImpl mapService;

    private User testUser;
    private User friendUser;
    private Map testMap;
    private MapMember testMapMember;

    @BeforeEach
    void setUp() {
        testUser = User.builder()
                .loginType("GOOGLE")
                .providerId("123456")
                .email("test@example.com")
                .name("Test User")
                .role(UserRole.USER)
                .friendCode("FRIEND123")
                .build();
        ReflectionTestUtils.setField(testUser, "userId", 1L);

        friendUser = User.builder()
                .loginType("GOOGLE")
                .providerId("789012")
                .email("friend@example.com")
                .name("Friend User")
                .role(UserRole.USER)
                .friendCode("FRIEND456")
                .build();
        ReflectionTestUtils.setField(friendUser, "userId", 2L);

        testMap = Map.from("Test Map", "Test Description", "Solo");
        ReflectionTestUtils.setField(testMap, "mapId", 1L);

        testMapMember = MapMember.from(testMap, testUser, MapMemberRole.OWNER);
    }

    @Test
    @DisplayName("지도 생성 성공")
    void createMap_Success() {
        // given
        CreateMapRequestDto request = new CreateMapRequestDto("New Map", "Description");
        Long userId = 1L;

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.existsByUserIdAndMapName(userId, request.getMapName())).thenReturn(false);
        when(mapRepository.save(any(Map.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // when
        Long mapId = mapService.createMap(request, null, userId);

        // then
        verify(userRepository).findById(userId);
        verify(mapMemberRepository).existsByUserIdAndMapName(userId, request.getMapName());
        verify(mapRepository).save(any(Map.class));
        verify(mapMemberRepository).save(any(MapMember.class));
    }

    @Test
    @DisplayName("지도 생성 실패 - 지도 이름 중복")
    void createMap_MapNameDuplicated() {
        // given
        CreateMapRequestDto request = new CreateMapRequestDto("Duplicate Map", "Description");
        Long userId = 1L;

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.existsByUserIdAndMapName(userId, request.getMapName())).thenReturn(true);

        // when & then
        assertThatThrownBy(() -> mapService.createMap(request, null, userId))
                .isInstanceOf(MapException.class)
                .hasMessage(MAP_NAME_DUPLICATED.getMessage());
    }

    @Test
    @DisplayName("지도 삭제 성공")
    void deleteMap_Success() {
        // given
        Long mapId = 1L;
        Long userId = 1L;

        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(testMapMember));

        // when
        mapService.deleteMap(mapId, userId);

        // then
        verify(mapMemberRepository).findByMap_MapIdAndUser_UserId(mapId, userId);
        verify(mapMemberRepository).deleteAllByMap(testMap);
        verify(mapRepository).delete(testMap);
    }

    @Test
    @DisplayName("지도 삭제 실패 - 삭제 권한 없음")
    void deleteMap_NoDeletePermission() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        MapMember editorMember = MapMember.from(testMap, testUser, MapMemberRole.EDITOR);

        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(editorMember));

        // when & then
        assertThatThrownBy(() -> mapService.deleteMap(mapId, userId))
                .isInstanceOf(MapException.class)
                .hasMessage(NO_DELETE_PERMISSION.getMessage());
    }

    @Test
    @DisplayName("지도 수정 성공")
    void updateMap_Success() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        UpdateMapRequestDto request = new UpdateMapRequestDto("Updated Map", "Updated Description");

        when(mapRepository.findById(mapId)).thenReturn(Optional.of(testMap));
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(testMapMember));
        when(mapMemberRepository.existsByUserIdAndMapNameExcludingMapId(userId, request.getMapName(), mapId)).thenReturn(false);

        // when
        mapService.updateMap(mapId, request, null, userId);

        // then
        verify(mapRepository).findById(mapId);
        verify(mapMemberRepository).findByMap_MapIdAndUser_UserId(mapId, userId);
        verify(mapMemberRepository).existsByUserIdAndMapNameExcludingMapId(userId, request.getMapName(), mapId);
        assertThat(testMap.getMapName()).isEqualTo("Updated Map");
        assertThat(testMap.getDescription()).isEqualTo("Updated Description");
    }

    @Test
    @DisplayName("지도 수정 실패 - 수정 권한 없음")
    void updateMap_NoUpdatePermission() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        UpdateMapRequestDto request = new UpdateMapRequestDto("Updated Map", "Updated Description");
        MapMember editorMember = MapMember.from(testMap, testUser, MapMemberRole.EDITOR);

        when(mapRepository.findById(mapId)).thenReturn(Optional.of(testMap));
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(editorMember));

        // when & then
        assertThatThrownBy(() -> mapService.updateMap(mapId, request, null, userId))
                .isInstanceOf(MapException.class)
                .hasMessage(NO_UPDATE_PERMISSION.getMessage());
    }

    @Test
    @DisplayName("지도 수정 실패 - 지도 이름 중복")
    void updateMap_MapNameDuplicated() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        UpdateMapRequestDto request = new UpdateMapRequestDto("Duplicate Map", "Updated Description");

        when(mapRepository.findById(mapId)).thenReturn(Optional.of(testMap));
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(testMapMember));
        when(mapMemberRepository.existsByUserIdAndMapNameExcludingMapId(userId, request.getMapName(), mapId)).thenReturn(true);

        // when & then
        assertThatThrownBy(() -> mapService.updateMap(mapId, request, null, userId))
                .isInstanceOf(MapException.class)
                .hasMessage(MAP_NAME_DUPLICATED.getMessage());
    }

    @Test
    @DisplayName("지도 목록 조회 성공 - PENDING 제외")
    void getMapList_ExcludePending() {
        // given
        Long userId = 1L;
        Map map1 = Map.from("Map 1", "Description 1", "Friends");
        ReflectionTestUtils.setField(map1, "mapId", 10L);
        Map map2 = Map.from("Map 2", "Description 2", "Couple");
        ReflectionTestUtils.setField(map2, "mapId", 20L);
        MapMember ownerMember = MapMember.from(map1, testUser, MapMemberRole.OWNER);
        MapMember pendingMember = MapMember.from(map2, testUser, testUser, MapMemberRole.PENDING);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findAllByUser(testUser)).thenReturn(Arrays.asList(ownerMember, pendingMember));
        when(mapMemberRepository.countByMap_MapIdAndMapMemberRoleNot(10L, MapMemberRole.PENDING)).thenReturn(1L);

        // when
        List<MapInfoDto> result = mapService.getMapList(userId);

        // then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getMapName()).isEqualTo("Map 1");
    }

    @Test
    @DisplayName("친구 초대 성공 - OWNER")
    void inviteFriend_Success_Owner() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        InviteFriendRequestDto request = new InviteFriendRequestDto(2L);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(testMapMember));
        when(userRepository.findById(request.getFriendId())).thenReturn(Optional.of(friendUser));
        when(friendshipRepository.existsFriendship(testUser, friendUser, FriendshipStatus.ACCEPTED)).thenReturn(true);
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, friendUser.getUserId())).thenReturn(Optional.empty());

        // when
        mapService.inviteFriend(mapId, request, userId);

        // then
        verify(mapMemberRepository).save(any(MapMember.class));
    }

    @Test
    @DisplayName("친구 초대 실패 - 초대 권한 없음")
    void inviteFriend_NoInvitePermission() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        InviteFriendRequestDto request = new InviteFriendRequestDto(2L);
        MapMember viewerMember = MapMember.from(testMap, testUser, MapMemberRole.VIEWER);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(viewerMember));

        // when & then
        assertThatThrownBy(() -> mapService.inviteFriend(mapId, request, userId))
                .isInstanceOf(MapException.class)
                .hasMessage(NO_INVITE_PERMISSION.getMessage());
    }

    @Test
    @DisplayName("친구 초대 실패 - 이미 지도 멤버")
    void inviteFriend_AlreadyMapMember() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        InviteFriendRequestDto request = new InviteFriendRequestDto(2L);
        MapMember existingMember = MapMember.from(testMap, friendUser, MapMemberRole.EDITOR);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(testMapMember));
        when(userRepository.findById(request.getFriendId())).thenReturn(Optional.of(friendUser));
        when(friendshipRepository.existsFriendship(testUser, friendUser, FriendshipStatus.ACCEPTED)).thenReturn(true);
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, friendUser.getUserId())).thenReturn(Optional.of(existingMember));

        // when & then
        assertThatThrownBy(() -> mapService.inviteFriend(mapId, request, userId))
                .isInstanceOf(MapException.class)
                .hasMessage(ALREADY_MAP_MEMBER.getMessage());
    }

    @Test
    @DisplayName("초대 수락 성공")
    void acceptInvitation_Success() {
        // given
        Long mapMemberId = 1L;
        Long userId = 1L;
        MapMember pendingMember = MapMember.from(testMap, testUser, friendUser, MapMemberRole.PENDING);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findById(mapMemberId)).thenReturn(Optional.of(pendingMember));

        // when
        mapService.acceptInvitation(mapMemberId, userId);

        // then
        assertThat(pendingMember.getMapMemberRole()).isEqualTo(MapMemberRole.EDITOR);
    }

    @Test
    @DisplayName("초대 수락 실패 - 초대받은 사용자 아님")
    void acceptInvitation_NotInvitedUser() {
        // given
        Long mapMemberId = 1L;
        Long userId = 1L;
        MapMember pendingMember = MapMember.from(testMap, friendUser, testUser, MapMemberRole.PENDING);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findById(mapMemberId)).thenReturn(Optional.of(pendingMember));

        // when & then
        assertThatThrownBy(() -> mapService.acceptInvitation(mapMemberId, userId))
                .isInstanceOf(MapException.class)
                .hasMessage(NOT_INVITED_USER.getMessage());
    }

    @Test
    @DisplayName("초대 거절 성공")
    void rejectInvitation_Success() {
        // given
        Long mapMemberId = 1L;
        Long userId = 1L;
        MapMember pendingMember = MapMember.from(testMap, testUser, friendUser, MapMemberRole.PENDING);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findById(mapMemberId)).thenReturn(Optional.of(pendingMember));

        // when
        mapService.rejectInvitation(mapMemberId, userId);

        // then
        verify(mapMemberRepository).delete(pendingMember);
    }

    @Test
    @DisplayName("초대 거절 실패 - 초대받은 사용자 아님")
    void rejectInvitation_NotInvitedUser() {
        // given
        Long mapMemberId = 1L;
        Long userId = 1L;
        MapMember pendingMember = MapMember.from(testMap, friendUser, testUser, MapMemberRole.PENDING);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findById(mapMemberId)).thenReturn(Optional.of(pendingMember));

        // when & then
        assertThatThrownBy(() -> mapService.rejectInvitation(mapMemberId, userId))
                .isInstanceOf(MapException.class)
                .hasMessage(NOT_INVITED_USER.getMessage());
    }


    @Test
    @DisplayName("초대 목록 조회 성공")
    void getInvitationList_Success() {
        // given
        Long userId = 1L;
        Map map1 = Map.from("Map 1", "Description 1", "Friends");
        Map map2 = Map.from("Map 2", "Description 2", "Couple");
        MapMember invitation1 = MapMember.from(map1, testUser, friendUser, MapMemberRole.PENDING);
        MapMember invitation2 = MapMember.from(map2, testUser, friendUser, MapMemberRole.PENDING);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.findAllByUserAndMapMemberRole(testUser, MapMemberRole.PENDING))
                .thenReturn(Arrays.asList(invitation1, invitation2));

        // when
        List<MapInvitationDto> result = mapService.getInvitationList(userId);

        // then
        assertThat(result).hasSize(2);
        assertThat(result.get(0).getMapName()).isEqualTo("Map 1");
        assertThat(result.get(1).getMapName()).isEqualTo("Map 2");
    }

    @Test
    @DisplayName("초대 목록 조회 실패 - 사용자 없음")
    void getInvitationList_UserNotFound() {
        // given
        Long userId = 1L;

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> mapService.getInvitationList(userId))
                .isInstanceOf(UserException.class)
                .hasMessage(USER_NOT_FOUND.getMessage());
    }

    @Test
    @DisplayName("지도 생성 성공 - 배경 이미지 포함")
    void createMap_WithBackgroundImage_Success() {
        // given
        CreateMapRequestDto request = new CreateMapRequestDto("New Map", "Description");
        Long userId = 1L;
        MultipartFile backgroundImage = new MockMultipartFile(
                "backgroundImage",
                "test.jpg",
                "image/jpeg",
                "test image content".getBytes()
        );
        S3UploadDto uploadResult = S3UploadDto.builder()
                .url("https://s3.amazonaws.com/bucket/test.jpg")
                .key("test.jpg")
                .build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(mapMemberRepository.existsByUserIdAndMapName(userId, request.getMapName())).thenReturn(false);
        when(s3Service.uploadImageFile(backgroundImage)).thenReturn(uploadResult);
        when(mapRepository.save(any(Map.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // when
        mapService.createMap(request, backgroundImage, userId);

        // then
        verify(s3Service).uploadImageFile(backgroundImage);
        verify(mapRepository).save(any(Map.class));
        verify(mapMemberRepository).save(any(MapMember.class));
    }

    @Test
    @DisplayName("지도 수정 성공 - 배경 이미지 변경")
    void updateMap_WithBackgroundImage_Success() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        UpdateMapRequestDto request = new UpdateMapRequestDto("Updated Map", "Updated Description");
        MultipartFile newBackgroundImage = new MockMultipartFile(
                "backgroundImage",
                "new_test.jpg",
                "image/jpeg",
                "new test image content".getBytes()
        );
        S3UploadDto uploadResult = S3UploadDto.builder()
                .url("https://s3.amazonaws.com/bucket/new_test.jpg")
                .key("new_test.jpg")
                .build();

        // 기존 배경 이미지가 있는 지도 설정
        ReflectionTestUtils.setField(testMap, "backgroundKey", "old_test.jpg");
        ReflectionTestUtils.setField(testMap, "backgroundUrl", "https://s3.amazonaws.com/bucket/old_test.jpg");

        when(mapRepository.findById(mapId)).thenReturn(Optional.of(testMap));
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(testMapMember));
        when(mapMemberRepository.existsByUserIdAndMapNameExcludingMapId(userId, request.getMapName(), mapId)).thenReturn(false);
        when(s3Service.uploadImageFile(newBackgroundImage)).thenReturn(uploadResult);

        // when
        mapService.updateMap(mapId, request, newBackgroundImage, userId);

        // then
        verify(s3Service).deleteFile("old_test.jpg");
        verify(s3Service).uploadImageFile(newBackgroundImage);
        assertThat(testMap.getBackgroundUrl()).isEqualTo("https://s3.amazonaws.com/bucket/new_test.jpg");
        assertThat(testMap.getBackgroundKey()).isEqualTo("new_test.jpg");
    }

    @Test
    @DisplayName("지도 수정 성공 - 기존 배경 이미지 없이 새 이미지 추가")
    void updateMap_AddBackgroundImage_Success() {
        // given
        Long mapId = 1L;
        Long userId = 1L;
        UpdateMapRequestDto request = new UpdateMapRequestDto("Updated Map", "Updated Description");
        MultipartFile newBackgroundImage = new MockMultipartFile(
                "backgroundImage",
                "new_test.jpg",
                "image/jpeg",
                "new test image content".getBytes()
        );
        S3UploadDto uploadResult = S3UploadDto.builder()
                .url("https://s3.amazonaws.com/bucket/new_test.jpg")
                .key("new_test.jpg")
                .build();

        when(mapRepository.findById(mapId)).thenReturn(Optional.of(testMap));
        when(mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)).thenReturn(Optional.of(testMapMember));
        when(mapMemberRepository.existsByUserIdAndMapNameExcludingMapId(userId, request.getMapName(), mapId)).thenReturn(false);
        when(s3Service.uploadImageFile(newBackgroundImage)).thenReturn(uploadResult);

        // when
        mapService.updateMap(mapId, request, newBackgroundImage, userId);

        // then
        verify(s3Service, never()).deleteFile(any());
        verify(s3Service).uploadImageFile(newBackgroundImage);
        assertThat(testMap.getBackgroundUrl()).isEqualTo("https://s3.amazonaws.com/bucket/new_test.jpg");
        assertThat(testMap.getBackgroundKey()).isEqualTo("new_test.jpg");
    }
}

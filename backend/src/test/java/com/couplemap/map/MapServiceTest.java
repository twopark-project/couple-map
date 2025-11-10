package com.couplemap.map;

import com.couplemap.global.exception.exceptions.MapException;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.dto.CreateMapRequestDto;
import com.couplemap.map.dto.InviteFriendRequestDto;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.service.MapService;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

@SpringBootTest
@Transactional
@DisplayName("지도 서비스 테스트")
class MapServiceTest {

    @Autowired
    private MapService mapService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MapMemberRepository mapMemberRepository;

    private User userA;
    private User userB;
    private User userC;

    @BeforeEach
    void setUp() {
        userA = userRepository.save(User.builder().email("userA@test.com").name("UserA").friendCode("userA_code").loginType("TEST").providerId("providerA").role(UserRole.USER).build());
        userB = userRepository.save(User.builder().email("userB@test.com").name("UserB").friendCode("userB_code").loginType("TEST").providerId("providerB").role(UserRole.USER).build());
        userC = userRepository.save(User.builder().email("userC@test.com").name("UserC").friendCode("userC_code").loginType("TEST").providerId("providerC").role(UserRole.USER).build());
    }

    @Test
    @DisplayName("지도 생성 성공")
    void createMapTest() {
        // given
        CreateMapRequestDto request = new CreateMapRequestDto("테스트 지도", "테스트 설명");

        // when
        Long mapId = mapService.createMap(request, userA.getUserId());

        // then
        assertThat(mapId).isNotNull();
        Optional<MapMember> mapMemberOptional = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userA.getUserId());
        assertThat(mapMemberOptional).isPresent();
        MapMember mapMember = mapMemberOptional.get();
        assertThat(mapMember.getMapMemberRole()).isEqualTo(MapMemberRole.OWNER);
        assertThat(mapMember.getUser()).isEqualTo(userA);
    }

    @Nested
    @DisplayName("지도 초대, 수락, 거절 테스트")
    class InvitationTest {

        private Long mapId;

        @BeforeEach
        void setUp() {
            CreateMapRequestDto request = new CreateMapRequestDto("초대 테스트용 지도", "");
            mapId = mapService.createMap(request, userA.getUserId());
        }

        @Test
        @DisplayName("지도 소유자가 친구를 성공적으로 초대")
        void inviteFriendSuccess() {
            // given
            InviteFriendRequestDto request = new InviteFriendRequestDto(userB.getFriendCode());

            // when
            mapService.inviteFriend(mapId, request, userA.getUserId());

            // then
            Optional<MapMember> invitedMemberOpt = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userB.getUserId());
            assertThat(invitedMemberOpt).isPresent();
            MapMember invitedMember = invitedMemberOpt.get();
            assertThat(invitedMember.getMapMemberRole()).isEqualTo(MapMemberRole.PENDING);
            assertThat(invitedMember.getInviter()).isEqualTo(userA);
        }

        @Test
        @DisplayName("멤버가 아닌 사람이 초대 시도 시 실패")
        void inviteFriendFail_NotAMember() {
            // given
            InviteFriendRequestDto request = new InviteFriendRequestDto(userB.getFriendCode());

            // when & then
            assertThrows(MapException.class, () -> {
                mapService.inviteFriend(mapId, request, userC.getUserId());
            });
        }

        @Test
        @DisplayName("초대받은 사용자가 초대를 수락")
        void acceptInvitationSuccess() {
            // given
            mapService.inviteFriend(mapId, new InviteFriendRequestDto(userB.getFriendCode()), userA.getUserId());
            MapMember pendingMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userB.getUserId()).get();

            // when
            mapService.acceptInvitation(pendingMember.getMapMemberId(), userB.getUserId());

            // then
            MapMember acceptedMember = mapMemberRepository.findById(pendingMember.getMapMemberId()).get();
            assertThat(acceptedMember.getMapMemberRole()).isEqualTo(MapMemberRole.EDITOR);
        }

        @Test
        @DisplayName("초대받지 않은 사용자가 수락 시도 시 실패")
        void acceptInvitationFail_NotInvitedUser() {
            // given
            mapService.inviteFriend(mapId, new InviteFriendRequestDto(userB.getFriendCode()), userA.getUserId());
            MapMember pendingMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userB.getUserId()).get();

            // when & then
            assertThrows(MapException.class, () -> {
                mapService.acceptInvitation(pendingMember.getMapMemberId(), userC.getUserId());
            });
        }

        @Test
        @DisplayName("초대받은 사용자가 초대를 거절")
        void rejectInvitationSuccess() {
            // given
            mapService.inviteFriend(mapId, new InviteFriendRequestDto(userB.getFriendCode()), userA.getUserId());
            MapMember pendingMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userB.getUserId()).get();

            // when
            mapService.rejectInvitation(pendingMember.getMapMemberId(), userB.getUserId());

            // then
            Optional<MapMember> rejectedMemberOpt = mapMemberRepository.findById(pendingMember.getMapMemberId());
            assertThat(rejectedMemberOpt).isNotPresent();
        }
    }
}

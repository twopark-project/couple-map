package com.couplemap.friend.service;

import com.couplemap.friend.dto.FriendRequestResponseDto;
import com.couplemap.friend.dto.SendFriendRequestDto;
import com.couplemap.global.exception.exceptions.FriendException;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.AssertionsForClassTypes.assertThatThrownBy;

@SpringBootTest
@Transactional
@DisplayName("FriendService")
class FriendServiceImplTest {

    @Autowired
    private FriendService friendService;

    @Autowired
    private UserRepository userRepository;

    private User requester;
    private User receiver;

    @BeforeEach
    void setUp() {
        requester = User.builder()
                .name("박민규")
                .email("test1@test.com")
                .loginType("GOOGLE")
                .role(UserRole.USER)
                .providerId("GOOGLE_1235")
                .friendCode("ABC123")
                .build();
        requester.updateNickname("박민규");
        requester = userRepository.save(requester);

        receiver = User.builder()
                .name("박성빈")
                .email("test2@test.com")
                .loginType("GOOGLE")
                .role(UserRole.USER)
                .providerId("GOOGLE_12345")
                .friendCode("ABC456")
                .build();
        receiver.updateNickname("박성빈");
        receiver = userRepository.save(receiver);
    }

    @Test
    @DisplayName("친구 요청 성공")
    void sendFriendRequest_Success() {
        SendFriendRequestDto dto = new SendFriendRequestDto(
                receiver.getFriendCode()
        );

        FriendRequestResponseDto result = friendService.sendFriendRequest(dto,requester.getUserId());

        assertThat(result).isNotNull();
        assertThat(result.getNickname()).isEqualTo("박성빈");
    }

    @Test
    @DisplayName("친구 요청 실패 - 사용자(요청자)를 찾을 수 없음")
    void sendFriendRequest_RequesterNotFound() {
        SendFriendRequestDto dto = new SendFriendRequestDto(
               "ERROR_CODE"
        );

        assertThatThrownBy(() -> friendService.sendFriendRequest(dto, 999999L))
                .isInstanceOf(UserException.class);
    }

    @Test
    @DisplayName("친구 요청 실패 - 잘못된 친구 코드")
    void sendFriendRequest_WrongFriendCode() {
        SendFriendRequestDto dto = new SendFriendRequestDto(
                "ERROR_CODE"
        );

        assertThatThrownBy(() -> friendService.sendFriendRequest(dto,requester.getUserId()))
                .isInstanceOf(FriendException.class);
    }
}

package com.couplemap.friend.service;

import com.couplemap.friend.dto.FriendRequestResponseDto;
import com.couplemap.friend.dto.SendFriendRequestDto;
import com.couplemap.global.exception.exceptions.FriendException;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.user.domain.LoginType;
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
                .loginType(LoginType.GOOGLE)
                .role(UserRole.USER)
                .providerId("GOOGLE_1235")
                .friendCode("ABC123")
                .build();
        requester = userRepository.save(requester);

        receiver = User.builder()
                .name("박성빈")
                .email("test2@test.com")
                .loginType(LoginType.GOOGLE)
                .role(UserRole.USER)
                .providerId("GOOGLE_12345")
                .friendCode("ABC456")
                .build();
        receiver = userRepository.save(receiver);
    }

    @Test
    @DisplayName("친구 요청 성공")
    void sendFriendRequest_Success() {
        SendFriendRequestDto dto = new SendFriendRequestDto(
                requester.getUserId(),
                receiver.getName(),
                receiver.getFriendCode()
        );

        FriendRequestResponseDto result = friendService.sendFriendRequest(dto);

        assertThat(result).isNotNull();
        assertThat(result.getName()).isEqualTo("박성빈");
    }

    @Test
    @DisplayName("친구 요청 실패 - 요청자를 찾을 수 없음")
    void sendFriendRequest_RequesterNotFound() {
        SendFriendRequestDto dto = new SendFriendRequestDto(
                999L,
                receiver.getName(),
                receiver.getFriendCode()
        );

        assertThatThrownBy(() -> friendService.sendFriendRequest(dto))
                .isInstanceOf(UserException.class);
    }

    @Test
    @DisplayName("친구 요청 실패 - 잘못된 친구 코드")
    void sendFriendRequest_WrongFriendCode() {
        SendFriendRequestDto dto = new SendFriendRequestDto(
                requester.getUserId(),
                receiver.getName(),
                "5456456456"
        );

        assertThatThrownBy(() -> friendService.sendFriendRequest(dto))
                .isInstanceOf(FriendException.class);
    }
}

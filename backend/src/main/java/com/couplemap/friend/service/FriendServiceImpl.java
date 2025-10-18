package com.couplemap.friend.service;

import com.couplemap.friend.domain.Friendship;
import com.couplemap.friend.domain.FriendshipStatus;
import com.couplemap.friend.dto.FriendRequestResponseDto;
import com.couplemap.friend.dto.SendFriendRequestDto;
import com.couplemap.friend.repository.FriendshipRepository;
import com.couplemap.global.exception.exceptions.FriendException;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.user.domain.User;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static com.couplemap.global.exception.code.FriendErrorCode.*;
import static com.couplemap.global.exception.code.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class FriendServiceImpl implements FriendService {

    private final FriendshipRepository friendshipRepository;
    private final UserRepository userRepository;

    @Transactional
    public FriendRequestResponseDto sendFriendRequest(SendFriendRequestDto sendFriendRequestDto, Long requesterId) {

        String code = sendFriendRequestDto.getFriendCode();

        User requester = userRepository.findById(requesterId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        User receiver = userRepository.findByFriendCode(code)
                .orElseThrow(() -> new FriendException(INVALID_FRIEND_CODE));

        /*
        이미 친구인 경우
         */
        if (friendshipRepository.existsFriendship(requester, receiver, FriendshipStatus.ACCEPTED)) {
            throw new FriendException(FRIEND_ALREADY_EXISTS);
        }

        /*
        이미 친구 요청을 보낸 경우 (아직 상대방에 수락 안함)
         */
        if (friendshipRepository.existsFriendship(requester, receiver, FriendshipStatus.PENDING)) {
            throw new FriendException(FRIEND_PENDING_EXISTS);
        }

        /*
        자기 자신에게 친구 요청을 보낸 경우
         */
        if (requesterId.equals(receiver.getUserId())) {
            throw new FriendException(CANNOT_FRIEND_YOURSELF);
        }


        Friendship friendship = Friendship.builder()
                .requester(requester)
                .receiver(receiver)
                .status(FriendshipStatus.PENDING)
                .build();

        friendshipRepository.save(friendship);

        return FriendRequestResponseDto.from(friendship);
    }
}

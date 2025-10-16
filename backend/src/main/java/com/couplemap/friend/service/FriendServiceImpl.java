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

import static com.couplemap.global.exception.code.FriendErrorCode.FRIEND_ALREADY_EXISTS;
import static com.couplemap.global.exception.code.FriendErrorCode.FRIEND_REQUEST_NOT_FOUND;
import static com.couplemap.global.exception.code.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class FriendServiceImpl implements FriendService {

    private final FriendshipRepository friendshipRepository;
    private final UserRepository userRepository;

    @Transactional
    public FriendRequestResponseDto sendFriendRequest(SendFriendRequestDto sendFriendRequestDto) {

        long requesterId = sendFriendRequestDto.getRequesterId();
        String receiverName = sendFriendRequestDto.getReceiverName();
        String code = sendFriendRequestDto.getFriendCode();

        User requester = userRepository.findById(requesterId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        User receiver = userRepository.findByName(receiverName)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));


        /*
        친구 코드를 찾을 수 없는 경우
         */
        if (!receiver.getFriendCode().equals(code)) {
            throw new FriendException(FRIEND_REQUEST_NOT_FOUND);
        }

        /*
        이미 친구인 경우
         */
        if (friendshipRepository.existsFriendship(requester, receiver, FriendshipStatus.ACCEPTED)) {
            throw new FriendException(FRIEND_ALREADY_EXISTS);
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

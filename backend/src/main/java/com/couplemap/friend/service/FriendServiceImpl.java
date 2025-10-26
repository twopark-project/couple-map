package com.couplemap.friend.service;

import com.couplemap.friend.domain.Friendship;
import com.couplemap.friend.dto.FriendListDto;
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

import java.util.ArrayList;
import java.util.List;

import static com.couplemap.friend.domain.FriendshipStatus.ACCEPTED;
import static com.couplemap.friend.domain.FriendshipStatus.PENDING;
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

        validateFriendRequest(requester, receiver);

        Friendship friendship = Friendship.createRequest(requester, receiver);

        friendshipRepository.save(friendship);

        return FriendRequestResponseDto.from(friendship);
    }

    @Transactional
    public FriendListDto getFriendList(Long userId) {
        List<User> friendList = new ArrayList<>();
        friendList.addAll(friendshipRepository.findFriendsWhereReceiver(userId, ACCEPTED));
        friendList.addAll(friendshipRepository.findFriendsWhereRequester(userId, ACCEPTED));

        return FriendListDto.from(friendList);
    }

    @Transactional
    public void reject(Long friendshipId, Long receiverId) {
        Friendship friendship = friendshipRepository.findById(friendshipId)
                .orElseThrow(() -> new FriendException(INVALID_FRIENDSHIP_ID));

        friendship.reject(receiverId);

        friendshipRepository.save(friendship);
    }

    @Transactional
    public void accept (Long friendshipId, Long receiverId) {
        Friendship friendship = friendshipRepository.findById(friendshipId)
                .orElseThrow(() -> new FriendException(INVALID_FRIENDSHIP_ID));

        friendship.accept(receiverId);

        friendshipRepository.save(friendship);
    }

    private void validateFriendRequest(User requester, User receiver) {
        if (requester.getUserId().equals(receiver.getUserId())) {
            throw new FriendException(CANNOT_FRIEND_YOURSELF);
        }

        if (friendshipRepository.existsFriendship(requester, receiver, ACCEPTED)) {
            throw new FriendException(FRIEND_ALREADY_EXISTS);
        }

        if (friendshipRepository.existsFriendship(requester, receiver, PENDING)) {
            throw new FriendException(FRIEND_PENDING_EXISTS);
        }
    }
}

package com.couplemap.friend.service;

import com.couplemap.friend.dto.FriendListResponseDto;
import com.couplemap.friend.dto.FriendPendingListResponseDto;
import com.couplemap.friend.dto.FriendRequestResponseDto;
import com.couplemap.friend.dto.SendFriendRequestDto;

public interface FriendService {
    FriendRequestResponseDto sendFriendRequest(SendFriendRequestDto dto, Long requesterId);
    FriendListResponseDto getFriendList(Long id);
    FriendPendingListResponseDto getFriendPendingList(Long id);
    void reject(Long friendshipId, Long requesterId);
    void accept(Long friendshipId, Long requesterId);
}

package com.couplemap.friend.service;

import com.couplemap.friend.dto.FriendRequestResponseDto;
import com.couplemap.friend.dto.SendFriendRequestDto;

public interface FriendService {
    FriendRequestResponseDto sendFriendRequest(SendFriendRequestDto dto);
}

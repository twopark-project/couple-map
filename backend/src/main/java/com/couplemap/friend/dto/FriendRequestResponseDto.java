package com.couplemap.friend.dto;

import com.couplemap.friend.domain.Friendship;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FriendRequestResponseDto {
    private String name;
    private Long friendId;

    public static FriendRequestResponseDto from(Friendship friendship) {
        return FriendRequestResponseDto.builder()
                .name(friendship.getReceiver().getName())
                .friendId(friendship.getFriendshipId())
                .build();
    }
}

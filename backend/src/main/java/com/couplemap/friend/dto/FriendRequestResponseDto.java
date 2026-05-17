package com.couplemap.friend.dto;

import com.couplemap.friend.domain.Friendship;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FriendRequestResponseDto {
    private String nickname;
    private Long friendId;

    public static FriendRequestResponseDto from(Friendship friendship) {
        return FriendRequestResponseDto.builder()
                .nickname(friendship.getReceiver().getNickname())
                .friendId(friendship.getFriendshipId())
                .build();
    }
}

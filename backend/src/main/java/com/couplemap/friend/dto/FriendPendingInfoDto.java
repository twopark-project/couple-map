package com.couplemap.friend.dto;

import com.couplemap.friend.domain.Friendship;
import com.couplemap.user.domain.User;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FriendPendingInfoDto {
    private final Long friendshipId;
    private final String nickname;
    private final String email;
    private final String imageUrl;

    public static  FriendPendingInfoDto from(Friendship friendship) {
        User user = friendship.getRequester();
        return FriendPendingInfoDto.builder()
                .friendshipId(friendship.getFriendshipId())
                .nickname(user.getNickname())
                .email(user.getEmail())
                .imageUrl(user.getProfileImageUrl())
                .build();
    }
}

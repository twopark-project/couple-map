package com.couplemap.friend.dto;

import com.couplemap.user.domain.User;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FriendPendingInfoDto {
    private final String name;
    private final String email;
    private final String imageUrl;

    public static  FriendPendingInfoDto from(User user) {
        return FriendPendingInfoDto.builder()
                .name(user.getName())
                .email(user.getEmail())
                .imageUrl(user.getProfileImageUrl())
                .build();
    }
}

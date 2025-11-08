package com.couplemap.friend.dto;

import com.couplemap.user.domain.User;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FriendInfoDto {

    private final Long id;
    private final String name;
    private final String email;
    private final String imageUrl;

    public static FriendInfoDto from(User user) {
        return FriendInfoDto.builder()
                .id(user.getUserId())
                .name(user.getName())
                .email(user.getEmail())
                .imageUrl(user.getProfileImageUrl())
                .build();
    }
}

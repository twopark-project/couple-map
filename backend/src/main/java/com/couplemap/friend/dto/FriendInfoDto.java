package com.couplemap.friend.dto;

import com.couplemap.user.domain.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FriendInfoDto {
    private Long id;
    private String name;
    private String email;
    private String imageUrl;

    public static FriendInfoDto from(User user) {
        return FriendInfoDto.builder()
                .id(user.getUserId())
                .name(user.getName())
                .email(user.getEmail())
                .imageUrl(user.getProfileImageUrl())
                .build();
    }
}

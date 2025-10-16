package com.couplemap.friend.dto;

import com.couplemap.friend.domain.Friendship;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Getter
public class FriendRequestResponseDto {
    private String name;

    public static FriendRequestResponseDto from(Friendship friendship) {
        return new FriendRequestResponseDto(friendship.getReceiver().getName());
    }
}

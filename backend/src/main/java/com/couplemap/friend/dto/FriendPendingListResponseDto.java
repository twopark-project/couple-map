package com.couplemap.friend.dto;

import com.couplemap.user.domain.User;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

@Getter
@AllArgsConstructor
public class FriendPendingListResponseDto {
    private final List<FriendPendingInfoDto> friendPendingInfoDtoList;

    public static FriendPendingListResponseDto from(List<User> users) {
        List<FriendPendingInfoDto> friendPendingList = new ArrayList<>();
        for (User user : users) {
            friendPendingList.add(FriendPendingInfoDto.from(user));
        }
        return new FriendPendingListResponseDto(friendPendingList);
    }
}

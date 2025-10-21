package com.couplemap.friend.dto;

import com.couplemap.user.domain.User;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

@Getter
@AllArgsConstructor
public class FriendListDto {
    private List<FriendInfoDto> friendList;

    public static FriendListDto from(List<User> users) {
        List<FriendInfoDto> friendInfoList = new ArrayList<>();
        for (User user : users) {
            friendInfoList.add(FriendInfoDto.from(user));
        }
        return new FriendListDto(friendInfoList);
    }
}

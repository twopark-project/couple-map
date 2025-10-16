package com.couplemap.friend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class SendFriendRequestDto {

    private long requesterId;
    private String receiverName;
    private String friendCode;
}

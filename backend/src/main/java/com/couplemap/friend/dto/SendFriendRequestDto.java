package com.couplemap.friend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class SendFriendRequestDto {
    @NotBlank(message = "친구 코드는 필수입니다.")
    private String friendCode;
}

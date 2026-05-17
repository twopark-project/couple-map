package com.couplemap.map.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class InviteFriendRequestDto {
    @NotNull(message = "초대할 친구 ID는 필수입니다.")
    private Long friendId;
}

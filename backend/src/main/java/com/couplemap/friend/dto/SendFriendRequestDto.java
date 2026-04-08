package com.couplemap.friend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class SendFriendRequestDto {
    @NotBlank(message = "친구 코드는 필수입니다.")
    @Size(min = 5, max = 5, message = "친구 코드는 5자리입니다.")
    @Pattern(regexp = "^[A-Z0-9]{5}$", message = "친구 코드는 A-Z, 0-9로 구성된 5자리입니다.")
    private String friendCode;
}

package com.couplemap.user.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class NicknameResponseDto {
    private final String nickname;
}

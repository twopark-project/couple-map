package com.couplemap.user.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ProfileImageResponseDto {
    private final String imageUrl;
}

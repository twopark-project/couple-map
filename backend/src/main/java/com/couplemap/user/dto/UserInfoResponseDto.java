package com.couplemap.user.dto;

import com.couplemap.user.domain.User;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class UserInfoResponseDto {
    
    private Long userId;
    
    private String email;
    
    private String name;
    
    private String nickname;
    
    private String profileImageUrl;
    
    private String friendCode;
    
    public static UserInfoResponseDto from(User user) {
        return UserInfoResponseDto.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .name(user.getName())
                .nickname(user.getNickname())
                .profileImageUrl(user.getProfileImageUrl())
                .friendCode(user.getFriendCode())
                .build();
    }
}

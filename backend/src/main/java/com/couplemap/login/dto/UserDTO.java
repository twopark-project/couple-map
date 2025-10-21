package com.couplemap.login.dto;

import com.couplemap.user.domain.UserRole;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class UserDTO {
    private Long userId;
    private UserRole role;
    private String oauthId;
    private String username;
}

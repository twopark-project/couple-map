package com.couplemap.login.dto;

import com.couplemap.user.domain.UserRole;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class UserDTO {
    private final Long userId;
    private final UserRole role;
    private final String oauthId;
    private final String username;
}

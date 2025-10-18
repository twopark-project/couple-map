package com.couplemap.login.dto;

import com.couplemap.user.domain.UserRole;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserDTO {
    private Long userId;
    private UserRole role;
    private String oauthId;
    private String username;

    @Builder
    public UserDTO(Long userId, UserRole role, String oauthId, String username) {
        this.userId = userId;
        this.role = role;
        this.oauthId = oauthId;
        this.username = username;
    }

}

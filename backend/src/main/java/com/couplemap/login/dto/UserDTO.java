package com.couplemap.login.dto;

import com.couplemap.user.domain.UserRole;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserDTO {
    private UserRole role;
    private String name;
    private String username;
}

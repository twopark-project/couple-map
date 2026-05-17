package com.couplemap.user.domain;

import lombok.Getter;

@Getter
public enum UserRole {
    ADMIN("관리자"),
    USER("일반 사용자");

    private final String description;

    UserRole(String description) {
        this.description = description;
    }

}

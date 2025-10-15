package com.couplemap.map.domain;

import lombok.Getter;

@Getter
public enum MapMemberRole {
    OWNER("지도 소유자"),
    EDITOR("편집자"),
    VIEWER("뷰어");

    private final String description;

    MapMemberRole(String description) {
        this.description = description;
    }
}

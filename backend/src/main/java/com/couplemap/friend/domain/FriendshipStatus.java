package com.couplemap.friend.domain;
import lombok.Getter;

@Getter
public enum FriendshipStatus {
    PENDING("대기중"),
    ACCEPTED("수락됨"),
    REJECTED("거절됨");

    private final String description;

    FriendshipStatus(String description) {
        this.description = description;
    }
}

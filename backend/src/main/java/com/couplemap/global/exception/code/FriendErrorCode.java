package com.couplemap.global.exception.code;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.CONFLICT;

@Getter
@RequiredArgsConstructor
public enum FriendErrorCode implements ErrorCode {

    FRIEND_ALREADY_EXISTS(CONFLICT, "이미 친구인 사용자입니다."),
    FRIEND_PENDING_EXISTS(CONFLICT, "이미 친구요청을 보낸 사용자입니다."),
    INVALID_FRIEND_CODE(BAD_REQUEST, "친구 코드가 일치하지 않습니다."),
    CANNOT_FRIEND_YOURSELF(BAD_REQUEST, "자기 자신에게 친구 요청을 보낼 수 없습니다.");

    private final HttpStatus httpStatus;
    private final String message;

    @Override
    public String getCodeName() {
        return this.name();
    }
}

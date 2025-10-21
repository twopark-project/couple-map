package com.couplemap.global.exception.code;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

import static org.springframework.http.HttpStatus.*;

@Getter
@RequiredArgsConstructor
public enum FriendErrorCode implements ErrorCode {

    FRIEND_ALREADY_EXISTS(CONFLICT, "이미 친구인 사용자입니다."),
    FRIEND_PENDING_EXISTS(CONFLICT, "이미 친구요청을 보낸 사용자입니다."),
    INVALID_FRIEND_CODE(BAD_REQUEST, "친구 코드가 일치하지 않습니다."),
    INVALID_FRIENDSHIP_ID(BAD_REQUEST,"존재 하지 않는 친구 관계 ID 입니다."),
    FRIEND_REQUEST_ALREADY_RESOLVED(CONFLICT, "이미 처리(수락 또는 거절)되어 상태를 변경할 수 없습니다."),
    NOT_MATCH_RECEIVER(FORBIDDEN, "본인에게 온 요청만 수락/거절할 수 있습니다"),
    CANNOT_FRIEND_YOURSELF(BAD_REQUEST, "자기 자신에게 친구 요청을 보낼 수 없습니다.");

    private final HttpStatus httpStatus;
    private final String message;

    @Override
    public String getCodeName() {
        return this.name();
    }
}

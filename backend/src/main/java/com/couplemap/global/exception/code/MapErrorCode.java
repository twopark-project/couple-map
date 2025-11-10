package com.couplemap.global.exception.code;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum MapErrorCode implements ErrorCode {
    NOT_MAP_MEMBER(HttpStatus.FORBIDDEN,  "지도 멤버가 아닙니다."),
    NO_INVITE_PERMISSION(HttpStatus.FORBIDDEN,  "초대 권한이 없습니다."),
    ALREADY_MAP_MEMBER(HttpStatus.CONFLICT,  "이미 지도에 참여하고 있는 멤버입니다."),
    MAP_NOT_FOUND(HttpStatus.NOT_FOUND,  "존재하지 않는 지도입니다."),
    INVITATION_NOT_FOUND(HttpStatus.NOT_FOUND,  "존재하지 않는 초대입니다."),
    NOT_INVITED_USER(HttpStatus.FORBIDDEN,  "초대받은 사용자가 아닙니다.");

    private final HttpStatus httpStatus;
    private final String message;
    @Override
    public String getCodeName() {
        return this.name();
    }
}

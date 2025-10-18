package com.couplemap.global.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;

/**
 * 친구 코드 생성 유틸리티
 * - 5자리 영숫자 코드 생성 (A-Z, 0-9)
 * - 중복 제거 로직은 추후 생각해보고 구현 할 예정
 */
@Slf4j
@Component
public class FriendCodeGenerator {

    private static final String CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final int CODE_LENGTH = 5;
    private final SecureRandom random = new SecureRandom();

    public String generateCode() {
        StringBuilder code = new StringBuilder(CODE_LENGTH);

        for (int i = 0; i < CODE_LENGTH; i++) {
            int index = random.nextInt(CHARACTERS.length());
            code.append(CHARACTERS.charAt(index));
        }

        log.debug("친구 코드 생성: {}", code);
        return code.toString();
    }
}
package com.couplemap.jwt.entity;

import jakarta.persistence.Id;
import lombok.Builder;
import lombok.Getter;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.TimeToLive;

@RedisHash(value = "refreshToken")
@Builder
@Getter
public class RefreshToken {
    @Id
    private final String id;

    private final String refreshToken;

    @TimeToLive
    private Long expiration;

    public static RefreshToken of(Long userId, String refreshToken, Long expiration) {
        return RefreshToken.builder()
                .id(String.valueOf(userId))
                .refreshToken(refreshToken)
                .expiration(expiration/1000)
                .build();
    }

}
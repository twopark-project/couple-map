package com.couplemap.jwt.util;

import com.couplemap.global.exception.exceptions.JwtException;
import com.couplemap.user.domain.UserRole;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import lombok.Builder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import static com.couplemap.global.exception.code.JwtErrorCode.JWT_TOKEN_GENERATION_FAILED;

@Component
public class JWTUtil {

    private SecretKey secretKey;

    public JWTUtil(@Value("${spring.jwt.secret}")String secret) {

        if (secret == null || secret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new JwtException(JWT_TOKEN_GENERATION_FAILED);
        }
        secretKey = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), Jwts.SIG.HS256.key().build().getAlgorithm());
    }

    public String getUsername(String token) {
        return Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload().get("username", String.class);
    }

    public UserRole getRole(String token) {

        String roleString = Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload().get("role", String.class);
        if (roleString.startsWith("ROLE_")) {
            roleString = roleString.substring(5);}
        return UserRole.valueOf(roleString);
    }

    public Long getUserId(String token) {
        return Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload().get("userId", Long.class);
    }

    public String getCategory(String token) {
        return Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload().get("category", String.class);
    }

    public Boolean isExpired(String token) {
        try {
            Date expiration = Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload()
                    .getExpiration();
            return expiration.before(new Date());
        } catch (ExpiredJwtException e) {
            return true;
        }
    }

    @Builder
    public String createJwt(String category, String username, String role, Long userId, Long expiredMs) {
        return Jwts.builder()
                .claim("username", username)
                .claim("role", role)
                .claim("category", category)
                .claim("userId", userId)
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis() + expiredMs))
                .signWith(secretKey)
                .compact();
    }
}
package com.couplemap.jwt.util;

import com.couplemap.login.dto.CustomOAuth2User;
import com.couplemap.login.dto.UserDTO;
import com.couplemap.user.domain.UserRole;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
public class JWTFilter extends OncePerRequestFilter {
    private final JWTUtil jwtUtil;

    public JWTFilter(JWTUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String authorization = request.getHeader("Authorization");
        String requestURI = request.getRequestURI();

        // Authorization 헤더가 없으면 인증 없이 다음 필터로 넘긴다.
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authorization.substring(7);

        try {
            if (jwtUtil.isExpired(token)) {
                log.debug("만료된 토큰 요청 - URI: {}", requestURI);
                filterChain.doFilter(request, response);
                return;
            }

            String category = jwtUtil.getCategory(token);
            if (!"access".equals(category)) {
                log.debug("ACCESS 토큰이 아닌 요청 - URI: {}", requestURI);
                filterChain.doFilter(request, response);
                return;
            }

            String username = jwtUtil.getUsername(token);
            UserRole role = jwtUtil.getRole(token);
            Long userId = jwtUtil.getUserId(token);

            UserDTO userDTO = UserDTO.builder()
                    .username(username)
                    .userId(userId)
                    .role(role)
                    .build();

            CustomOAuth2User customOAuth2User = new CustomOAuth2User(userDTO);
            Authentication authToken = new UsernamePasswordAuthenticationToken(
                    customOAuth2User,
                    null,
                    customOAuth2User.getAuthorities()
            );
            SecurityContextHolder.getContext().setAuthentication(authToken);
        } catch (io.jsonwebtoken.JwtException | IllegalArgumentException e) {
            SecurityContextHolder.clearContext();
            log.debug("유효하지 않은 토큰 요청 - URI: {}", requestURI);
            filterChain.doFilter(request, response);
            return;
        }

        filterChain.doFilter(request, response);
    }
}

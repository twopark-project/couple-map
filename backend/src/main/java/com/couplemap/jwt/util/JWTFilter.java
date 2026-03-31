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


            // Authorization 헤더 검증
            if (authorization == null || !authorization.startsWith("Bearer ")) {
                log.warn("토큰 없음 또는 형식 오류 - URI: {}", requestURI);
                filterChain.doFilter(request, response);
                return;
            }
    
            // "Bearer " 제거하고 토큰만 추출
            String token = authorization.substring(7);

            //토큰 소멸 시간 검증
            if (jwtUtil.isExpired(token)) {
                log.warn("토큰 만료 - URI: {}", requestURI);
                filterChain.doFilter(request, response);
                return;
            }

            // Access Token 확인
            String category = jwtUtil.getCategory(token);
            if (!"access".equals(category)) {
                log.warn("ACCESS 토큰이 아님 - URI: {}", requestURI);
                filterChain.doFilter(request, response);
                return;
            }


            //토큰에서 username과 role 획득
            String username = jwtUtil.getUsername(token);
            UserRole role = jwtUtil.getRole(token);
            Long userId = jwtUtil.getUserId(token);

            //userDTO를 생성하여 값 set
            UserDTO userDTO = UserDTO.builder()
                    .username(username)
                    .userId(userId)
                    .role(role)
                    .build();

            //UserDetails에 회원 정보 객체 담기
            CustomOAuth2User customOAuth2User = new CustomOAuth2User(userDTO);

            //스프링 시큐리티 인증 토큰 생성
            Authentication authToken = new UsernamePasswordAuthenticationToken(customOAuth2User, null, customOAuth2User.getAuthorities());
            //세션에 사용자 등록
            SecurityContextHolder.getContext().setAuthentication(authToken);

            filterChain.doFilter(request, response);
        }
    }

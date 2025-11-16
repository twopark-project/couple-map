package com.couplemap.global.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {
    @Bean
    public OpenAPI openAPI() {

        SecurityScheme accessTokenScheme = new SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .scheme("Bearer")
                .bearerFormat("JWT")
                .name("Bearer Authentication")
                .description("API 요청 시 사용하는 Access Token");

        SecurityScheme refreshTokenScheme = new SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .scheme("Bearer")
                .bearerFormat("JWT")
                .name("Refresh Token (Bearer)")
                .description("토큰 재발급 시 사용하는 Refresh Token");

        return new OpenAPI()
                .info(new Info()
                        .title("CoupleMap API")
                        .version("1.0")
                        .description("커플맵 API 문서"))
                .components(new Components()
                        .addSecuritySchemes("Bearer Authentication", accessTokenScheme)
                        .addSecuritySchemes("Refresh Token (Bearer)", refreshTokenScheme)
                )
                .addSecurityItem(new SecurityRequirement()
                        .addList("Bearer Authentication"));
    }
}
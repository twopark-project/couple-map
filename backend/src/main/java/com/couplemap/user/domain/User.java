package com.couplemap.user.domain;

import com.couplemap.global.common.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Table(name = "users")
public class User extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private UserRole role;

    @Column(name = "email", nullable = false, length = 100)
    private String email;

    @Column(name = "name", nullable = false, length = 50)
    private String name;

    // 프로필 이미지 등록용 (AWS S3)
    @Column(name = "profile_image_url", length = 500)
    private String profileImageUrl;

    // 프로필 이미지 삭제용 (AWS S3)
    @Column(name = "profile_image_key", length = 200)
    private String profileImageKey;

    @Enumerated(EnumType.STRING)
    @Column(name = "login_type", nullable = false)
    private LoginType loginType;  // GOOGLE, NAVER

    // OAuth 제공 ID
    @Column(name = "provider_id", nullable = false, length = 200)
    private String providerId;

}
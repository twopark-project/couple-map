package com.couplemap.map.domain;

import com.couplemap.global.common.BaseEntity;
import com.couplemap.user.domain.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "map_members")
public class MapMember extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "map_member_id")
    private Long mapMemberId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "map_id", nullable = false)
    private Map map;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "map_member_role", nullable = false, length = 20)
    private MapMemberRole mapMemberRole;

    @Builder
    public static MapMember from(Map map, User user, MapMemberRole role) {
        return MapMember.builder()
                .map(map)
                .user(user)
                .role(role)
                .build();
    }
}

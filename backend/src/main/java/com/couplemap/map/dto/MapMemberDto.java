package com.couplemap.map.dto;

import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import lombok.Getter;

@Getter
public class MapMemberDto {
    private final Long userId;
    private final String nickname;
    private final String profileImageUrl;
    private final MapMemberRole role;

    public MapMemberDto(Long userId, String nickname, String profileImageUrl, MapMemberRole role) {
        this.userId = userId;
        this.nickname = nickname;
        this.profileImageUrl = profileImageUrl;
        this.role = role;
    }

    public static MapMemberDto from(MapMember mapMember) {
        return new MapMemberDto(
                mapMember.getUser().getUserId(),
                mapMember.getUser().getNickname(),
                mapMember.getUser().getProfileImageUrl(),
                mapMember.getMapMemberRole()
        );
    }
}

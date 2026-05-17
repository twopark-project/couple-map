package com.couplemap.map.dto;

import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public class MapMemberDto {
    private final Long userId;
    private final String nickname;
    private final String profileImageUrl;
    private final MapMemberRole role;

    public static MapMemberDto from(MapMember mapMember) {
        return new MapMemberDto(
                mapMember.getUser().getUserId(),
                mapMember.getUser().getNickname(),
                mapMember.getUser().getProfileImageUrl(),
                mapMember.getMapMemberRole()
        );
    }
}

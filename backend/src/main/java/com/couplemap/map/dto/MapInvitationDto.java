package com.couplemap.map.dto;

import com.couplemap.map.domain.MapMember;
import lombok.Getter;

@Getter
public class MapInvitationDto {
    private final Long mapMemberId;
    private final String mapName;
    private final String inviterNickname;

    public MapInvitationDto(Long mapMemberId, String mapName, String inviterNickname) {
        this.mapMemberId = mapMemberId;
        this.mapName = mapName;
        this.inviterNickname = inviterNickname;
    }

    public static MapInvitationDto from(MapMember mapMember) {
        return new MapInvitationDto(
                mapMember.getMapMemberId(),
                mapMember.getMap().getMapName(),
                mapMember.getInviter().getNickname()
        );
    }
}

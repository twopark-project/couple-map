package com.couplemap.map.dto;

import com.couplemap.map.domain.MapMember;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class MapInvitationDto {
    private final Long mapMemberId;
    private final String mapName;
    private final String inviterNickname;
    private final LocalDateTime createdAt;

    public MapInvitationDto(Long mapMemberId, String mapName, String inviterNickname, LocalDateTime createdAt) {
        this.mapMemberId = mapMemberId;
        this.mapName = mapName;
        this.inviterNickname = inviterNickname;
        this.createdAt = createdAt;
    }

    public static MapInvitationDto from(MapMember mapMember) {
        return new MapInvitationDto(
                mapMember.getMapMemberId(),
                mapMember.getMap().getMapName(),
                mapMember.getInviter().getNickname(),
                mapMember.getCreatedAt()
        );
    }
}

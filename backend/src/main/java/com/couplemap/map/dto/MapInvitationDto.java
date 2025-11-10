package com.couplemap.map.dto;

import lombok.Getter;

@Getter
public class MapInvitationDto {
    private final Long mapMemberId;
    private final String mapName;
    private final String inviterName;

    public MapInvitationDto(Long mapMemberId, String mapName, String inviterName) {
        this.mapMemberId = mapMemberId;
        this.mapName = mapName;
        this.inviterName = inviterName;
    }
}

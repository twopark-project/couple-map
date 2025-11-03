package com.couplemap.map.dto;

import lombok.Getter;

@Getter
public class MapInvitationDto {
    private final Long mapMemberId;
    private final String mapName;
    //TODO: 초대한 사람 이름 추가하면 좋을 듯

    public MapInvitationDto(Long mapMemberId, String mapName) {
        this.mapMemberId = mapMemberId;
        this.mapName = mapName;
    }
}

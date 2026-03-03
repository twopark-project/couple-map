package com.couplemap.map.dto;

import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import lombok.Getter;

@Getter
public class MapListDto {
    private final Long mapId;
    private final String mapName;
    private final String description;
    private final String backgroundUrl;
    private final MapMemberRole myRole;
    private long memberCount;

    public MapListDto(Long mapId, String mapName, String description, String backgroundUrl, MapMemberRole myRole, long memberCount) {
        this.mapId = mapId;
        this.mapName = mapName;
        this.description = description;
        this.backgroundUrl = backgroundUrl;
        this.myRole = myRole;
        this.memberCount = memberCount;
    }

    public static MapListDto from(MapMember mapMember, long memberCount) {
        return new MapListDto(
                mapMember.getMap().getMapId(),
                mapMember.getMap().getMapName(),
                mapMember.getMap().getDescription(),
                mapMember.getMap().getBackgroundUrl(),
                mapMember.getMapMemberRole(),
                memberCount
        );
    }
}

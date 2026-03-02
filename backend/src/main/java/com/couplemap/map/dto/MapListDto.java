package com.couplemap.map.dto;

import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import lombok.Getter;

@Getter
public class MapListDto {
    private Long mapId;
    private String mapName;
    private String description;
    private MapMemberRole myRole;

    public
    MapListDto(Long mapId, String mapName, String description, MapMemberRole myRole) {
        this.mapId = mapId;
        this.mapName = mapName;
        this.description = description;
        this.myRole = myRole;
    }

    public static MapListDto from(MapMember mapMember) {
        return new MapListDto(
                mapMember.getMap().getMapId(),
                mapMember.getMap().getMapName(),
                mapMember.getMap().getDescription(),
                mapMember.getMapMemberRole()
        );
    }
}

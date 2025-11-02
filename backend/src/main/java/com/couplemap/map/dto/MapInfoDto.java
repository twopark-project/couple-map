package com.couplemap.map.dto;

import com.couplemap.map.domain.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class MapInfoDto {
    private Long mapId;
    private String mapName;

    public static MapInfoDto from(Map map){
        return MapInfoDto.builder()
                .mapId(map.getMapId())
                .mapName(map.getMapName())
                .build();
    }
}

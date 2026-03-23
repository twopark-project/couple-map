package com.couplemap.map.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class UpdateMapRequestDto {
    private String mapName;
    private String description;
    private String category;
}

package com.couplemap.memory.dto;

import com.couplemap.memory.domain.Memory;
import lombok.Getter;

import java.time.LocalDate;

@Getter
public class CalendarMemoryResponseDto {
    private final Long mapId;
    private final Long memoryId;
    private final String title;
    private final String placeName;
    private final LocalDate memoryDate;
    private final String category;
    private final String thumbnailUrl;

    public CalendarMemoryResponseDto(Memory memory, String thumbnailUrl) {
        this.mapId = memory.getMap().getMapId();
        this.memoryId = memory.getMemoryId();
        this.title = memory.getTitle();
        this.placeName = memory.getPlaceName();
        this.memoryDate = memory.getMemoryDate();
        this.category = memory.getCategory();
        this.thumbnailUrl = thumbnailUrl;
    }
}

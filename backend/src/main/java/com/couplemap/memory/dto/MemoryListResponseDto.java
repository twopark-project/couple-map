package com.couplemap.memory.dto;

import com.couplemap.memory.domain.Memory;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
public class MemoryListResponseDto {
    private final Long memoryId;
    private final String title;
    private final String placeName;
    private final BigDecimal latitude;
    private final BigDecimal longitude;
    private final LocalDate memoryDate;
    private final String category;
    private final String thumbnailUrl;

    public MemoryListResponseDto(Memory memory, String thumbnailUrl) {
        this.memoryId = memory.getMemoryId();
        this.title = memory.getTitle();
        this.placeName = memory.getPlaceName();
        this.latitude = memory.getLatitude();
        this.longitude = memory.getLongitude();
        this.memoryDate = memory.getMemoryDate();
        this.category = memory.getCategory();
        this.thumbnailUrl = thumbnailUrl;
    }
}

package com.couplemap.memory.dto;

import com.couplemap.memory.domain.Memory;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
public class MemoryListResponseDto {
    private final Long memoryId;
    private final String title;
    private final String placeName;
    private final BigDecimal latitude;
    private final BigDecimal longitude;

    public MemoryListResponseDto(Memory memory) {
        this.memoryId = memory.getMemoryId();
        this.title = memory.getTitle();
        this.placeName = memory.getPlaceName();
        this.latitude = memory.getLatitude();
        this.longitude = memory.getLongitude();
    }
}

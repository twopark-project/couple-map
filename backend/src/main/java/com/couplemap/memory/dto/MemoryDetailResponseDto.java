package com.couplemap.memory.dto;

import com.couplemap.memory.domain.Memory;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
public class MemoryDetailResponseDto {
    private final Long memoryId;
    private final String title;
    private final String content;
    private final String placeName;
    private final LocalDate memoryDate;
    private final BigDecimal latitude;
    private final BigDecimal longitude;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;
    private final List<MediaFileDto> mediaFiles;

    public MemoryDetailResponseDto(Memory memory, List<MediaFileDto> mediaFiles) {
        this.memoryId = memory.getMemoryId();
        this.title = memory.getTitle();
        this.content = memory.getContent();
        this.placeName = memory.getPlaceName();
        this.memoryDate = memory.getMemoryDate();
        this.latitude = memory.getLatitude();
        this.longitude = memory.getLongitude();
        this.createdAt = memory.getCreatedAt();
        this.updatedAt = memory.getUpdatedAt();
        this.mediaFiles = mediaFiles;
    }
}

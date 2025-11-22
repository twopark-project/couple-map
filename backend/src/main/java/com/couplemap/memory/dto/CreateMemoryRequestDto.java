package com.couplemap.memory.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@NoArgsConstructor
public class CreateMemoryRequestDto {
    private String title;
    private String content;
    private String placeName;
    private LocalDate memoryDate;
    private BigDecimal latitude;
    private BigDecimal longitude;
}

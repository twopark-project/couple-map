package com.couplemap.memory.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class CreateMemoryRequestDto {

    @NotBlank(message = "제목은 필수입니다.")
    @Size(max = 50, message = "제목은 최대 50자까지 입력 가능합니다.")
    private String title;

    private String content;

    @NotBlank(message = "장소명은 필수입니다.")
    private String placeName;

    @NotNull(message = "추억 날짜는 필수입니다.")
    private LocalDate memoryDate;
    @NotNull(message = "위도는 필수입니다.")
    private BigDecimal latitude;
    @NotNull(message = "경도는 필수입니다.")
    private BigDecimal longitude;
}

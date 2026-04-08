package com.couplemap.map.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class CreateMapRequestDto {
    @NotBlank(message = "지도 이름은 필수입니다.")
    private String mapName;

    private String description;

    @NotBlank(message = "지도 카테고리는 필수입니다.")
    private String category;
}

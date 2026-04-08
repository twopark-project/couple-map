package com.couplemap.map.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class CreateMapRequestDto {
    @NotBlank(message = "지도 이름은 필수입니다.")
    @Size(max = 20)
    private String mapName;

    @Size(max = 20)
    private String description;

    @NotBlank(message = "지도 카테고리는 필수입니다.")
    private String category;
}

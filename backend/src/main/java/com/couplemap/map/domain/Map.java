package com.couplemap.map.domain;

import com.couplemap.global.common.BaseEntity;
import jakarta.persistence.*;
import lombok.*;


@Entity
@Getter
@Builder(access = AccessLevel.PRIVATE)
@AllArgsConstructor
@Table(name = "maps")
@NoArgsConstructor
public class Map extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "map_id")
    private Long mapId;

    @Column(name = "map_name", nullable = false, length = 100)
    private String mapName;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "background_url")
    private String backgroundUrl;

    @Column(name = "background_key")
    private String backgroundKey;

    @Column(name = "category", length = 10)
    private String category;

    public static Map from(String mapName, String description, String category) {
        return Map.builder()
                .mapName(mapName)
                .description(description)
                .category(category)
                .build();
    }

    public void update(String mapName, String description, String category) {
        this.mapName = mapName;
        this.description = description;
        this.category = category;
    }

    public void updateBackground(String backgroundUrl, String backgroundKey) {
        this.backgroundUrl = backgroundUrl;
        this.backgroundKey = backgroundKey;
    }

    public void deleteBackground() {
        this.backgroundUrl = null;
        this.backgroundKey = null;
    }
}

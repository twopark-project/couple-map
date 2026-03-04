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

    public static Map from(String mapName, String description) {
        return Map.builder()
                .mapName(mapName)
                .description(description)
                .build();
    }

    public void update(String mapName, String description) {
        this.mapName = mapName;
        this.description = description;
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

package com.couplemap.map.domain;

import com.couplemap.global.common.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
@Table(name = "maps")
public class Map extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "map_id")
    private Long mapId;

    @Column(name = "map_name", nullable = false, length = 100)
    private String mapName;

    @Column(name = "description", length = 500)
    private String description;

}

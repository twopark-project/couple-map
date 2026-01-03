package com.couplemap.memory.domain;

import com.couplemap.global.common.BaseEntity;
import com.couplemap.map.domain.Map;
import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.dto.UpdateMemoryRequestDto;
import com.couplemap.user.domain.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "memories")
public class Memory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "memory_id")
    private Long memoryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "map_id", nullable = false)
    private Map map;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "title", nullable = false, length = 100)
    private String title;

    @Column(name = "content",length = 1000)
    private String content;

    @Column(name = "place_name", nullable = false, length = 100)
    private String placeName;

    @Column(name = "memory_date")
    private LocalDate memoryDate;

    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    @Builder
    private Memory(Map map, User user, String title, String content, String placeName, LocalDate memoryDate, BigDecimal latitude, BigDecimal longitude) {
        this.map = map;
        this.user = user;
        this.title = title;
        this.content = content;
        this.placeName = placeName;
        this.memoryDate = memoryDate;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public static Memory from(CreateMemoryRequestDto request, Map map, User user) {
        return Memory.builder()
                .map(map)
                .user(user)
                .title(request.getTitle())
                .content(request.getContent())
                .placeName(request.getPlaceName())
                .memoryDate(request.getMemoryDate())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .build();
    }

    public void update(UpdateMemoryRequestDto request) {
        this.title = request.getTitle();
        this.content = request.getContent();
        this.placeName = request.getPlaceName();
        this.memoryDate = request.getMemoryDate();
    }
}

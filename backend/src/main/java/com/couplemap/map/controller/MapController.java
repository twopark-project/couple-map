package com.couplemap.map.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.map.dto.CreateMapRequest;
import com.couplemap.map.dto.MapListDto;
import com.couplemap.map.service.MapService;
import com.couplemap.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/map")
public class MapController {

    private final MapService mapService;

    @PostMapping
    public ResponseEntity<ApiResponse<Long>> createMap(@RequestBody CreateMapRequest request, @AuthenticationPrincipal User user) {
        Long mapId = mapService.createMap(request, user);
        return ResponseEntity.created(URI.create("/api/map/" + mapId))
                .body(ApiResponse.success(mapId, "지도가 성공적으로 생성되었습니다."));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<MapListDto>>> getMapList(@AuthenticationPrincipal User user) {
        List<MapListDto> mapList = mapService.getMapList(user);
        return ResponseEntity.ok(ApiResponse.success(mapList, "지도 목록 조회가 완료되었습니다."));
    }
}

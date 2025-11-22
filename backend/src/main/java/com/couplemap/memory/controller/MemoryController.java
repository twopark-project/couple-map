package com.couplemap.memory.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.service.MemoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.net.URI;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/maps/{mapId}/memories")
public class MemoryController {

    private final MemoryService memoryService;

    @PostMapping(consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<ApiResponse<Long>> createMemory(
            @PathVariable Long mapId,
            @RequestPart("request") CreateMemoryRequestDto request,
            @RequestPart("files") List<MultipartFile> files,
            @AuthenticationPrincipal(expression = "userId") Long userId) {
        Long memoryId = memoryService.createMemory(mapId, request, files, userId);
        return ResponseEntity.created(URI.create("/api/maps/" + mapId + "/memories/" + memoryId))
                .body(ApiResponse.success(memoryId, "추억이 성공적으로 생성되었습니다."));
    }
}

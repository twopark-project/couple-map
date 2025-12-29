package com.couplemap.memory.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.dto.MemoryListResponseDto;
import com.couplemap.memory.dto.UpdateMemoryRequestDto;
import com.couplemap.memory.service.MemoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.net.URI;
import java.util.List;

@Tag(name = "Memory", description = "추억 관리 API")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/maps/{mapId}/memories")
public class MemoryController {

    private final MemoryService memoryService;

    @Operation(summary = "추억 생성", description = "지도에 새로운 추억을 사진과 함께 등록합니다.")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Long>> createMemory(
            @PathVariable Long mapId,
            @Valid @RequestPart("request") CreateMemoryRequestDto request,
            @RequestPart(value = "files", required = false) List<MultipartFile> files,
            @AuthenticationPrincipal(expression = "userId") Long userId) {
        Long memoryId = memoryService.createMemory(mapId, request, files, userId);
        return ResponseEntity.created(URI.create("/api/maps/" + mapId + "/memories/" + memoryId))
                .body(ApiResponse.success(memoryId, "추억이 성공적으로 생성되었습니다."));
    }

    @Operation(summary = "추억 목록 조회", description = "특정 지도에 속한 모든 추억의 목록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<MemoryListResponseDto>>> getMemoryList(
            @PathVariable Long mapId,
            @AuthenticationPrincipal(expression = "userId") Long userId) {
        List<MemoryListResponseDto> memoryList = memoryService.getMemoryList(mapId, userId);
        return ResponseEntity.ok(ApiResponse.success(memoryList, "추억 목록 조회가 완료되었습니다."));
    }

    @Operation(summary = "추억 삭제", description = "추억을 삭제합니다. 작성자만 삭제할 수 있습니다.")
    @DeleteMapping("/{memoryId}")
    public ResponseEntity<ApiResponse<Void>> deleteMemory(
            @PathVariable Long mapId,
            @PathVariable Long memoryId,
            @AuthenticationPrincipal(expression = "userId") Long userId) {
        memoryService.deleteMemory(mapId, memoryId, userId);
        return ResponseEntity.ok(ApiResponse.success("추억이 성공적으로 삭제되었습니다."));
    }

    @Operation(summary = "추억 수정", description = "추억을 수정합니다. 작성자만 수정할 수 있습니다.")
    @PutMapping(value = "/{memoryId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Long>> updateMemory(
            @PathVariable Long mapId,
            @PathVariable Long memoryId,
            @Valid @RequestPart("request") UpdateMemoryRequestDto request,
            @RequestPart(value = "files", required = false) List<MultipartFile> files,
            @AuthenticationPrincipal(expression = "userId") Long userId) {
        Long updatedMemoryId = memoryService.updateMemory(mapId, memoryId, request, files, userId);
        return ResponseEntity.ok(ApiResponse.success(updatedMemoryId, "추억이 성공적으로 수정되었습니다."));
    }
}

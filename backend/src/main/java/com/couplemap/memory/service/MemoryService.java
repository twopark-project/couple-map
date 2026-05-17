package com.couplemap.memory.service;

import com.couplemap.memory.dto.CalendarMemoryResponseDto;
import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.dto.MemoryDetailResponseDto;
import com.couplemap.memory.dto.MemoryListResponseDto;
import com.couplemap.memory.dto.MemoryMarkerResponseDto;
import com.couplemap.memory.dto.UpdateMemoryRequestDto;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface MemoryService {
    Long createMemory(Long mapId, CreateMemoryRequestDto request, List<MultipartFile> files, Long userId);
    Slice<MemoryListResponseDto> getMemoryList(Long mapId, Long userId, Pageable pageable);
    List<MemoryMarkerResponseDto> getMemoryMarkers(Long mapId, Long userId);
    MemoryDetailResponseDto getMemoryDetail(Long mapId, Long memoryId, Long userId);
    void deleteMemory(Long mapId, Long memoryId, Long userId);
    Long updateMemory(Long mapId, Long memoryId, UpdateMemoryRequestDto request, List<MultipartFile> files, Long userId);
    List<CalendarMemoryResponseDto> getCalendarMemories(int year, Long userId);
}

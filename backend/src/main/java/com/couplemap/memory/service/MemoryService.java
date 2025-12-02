package com.couplemap.memory.service;

import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.dto.MemoryListResponseDto;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface MemoryService {
    Long createMemory(Long mapId, CreateMemoryRequestDto request, List<MultipartFile> files, Long userId);
    List<MemoryListResponseDto> getMemoryList(Long mapId, Long userId);
}

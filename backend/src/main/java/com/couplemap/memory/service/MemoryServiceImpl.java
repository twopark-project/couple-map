package com.couplemap.memory.service;

import com.couplemap.global.exception.code.MemoryErrorCode;
import com.couplemap.global.exception.code.S3ErrorCode;
import com.couplemap.global.exception.exceptions.MapException;
import com.couplemap.global.exception.exceptions.MemoryException;
import com.couplemap.global.exception.exceptions.S3Exception;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.global.filecleanup.FileCleanupService;
import com.couplemap.global.s3.S3Service;
import com.couplemap.global.s3.S3UploadDto;
import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.mediaFile.domain.MediaFile;
import com.couplemap.mediaFile.domain.MediaFileType;
import com.couplemap.mediaFile.repository.MediaFileRepository;
import com.couplemap.memory.domain.Memory;
import com.couplemap.memory.dto.CalendarMemoryResponseDto;
import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.dto.MediaFileDto;
import com.couplemap.memory.dto.MemoryDetailResponseDto;
import com.couplemap.memory.dto.MemoryListResponseDto;
import com.couplemap.memory.dto.MemoryMarkerResponseDto;
import com.couplemap.memory.dto.UpdateMemoryRequestDto;
import com.couplemap.memory.repository.MemoryRepository;
import com.couplemap.user.domain.User;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.SliceImpl;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

import static com.couplemap.global.exception.code.MapErrorCode.*;
import static com.couplemap.global.exception.code.MemoryErrorCode.*;
import static com.couplemap.global.exception.code.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemoryServiceImpl implements MemoryService {

    private final MemoryRepository memoryRepository;
    private final MapRepository mapRepository;
    private final UserRepository userRepository;
    private final MapMemberRepository mapMemberRepository;
    private final S3Service s3Service;
    private final FileCleanupService fileCleanupService;
    private final MediaFileRepository mediaFileRepository;

    @Transactional
    @Override
    public Long createMemory(Long mapId, CreateMemoryRequestDto request, List<MultipartFile> files, Long userId) {
        // 1. 사용자 및 지도 멤버 정보 조회, 권한 확인
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        MapMember mapMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)
                .orElseThrow(() -> new MapException(NOT_MAP_MEMBER));

        if (mapMember.getMapMemberRole() != MapMemberRole.OWNER && mapMember.getMapMemberRole() != MapMemberRole.EDITOR) {
            throw new MapException(NOT_MAP_MEMBER);
        }

        Map map = mapRepository.findById(mapId)
                .orElseThrow(() -> new MapException(MAP_NOT_FOUND));

        // 2. Memory 객체 생성 및 저장
        Memory newMemory = Memory.from(request, map, user);
        memoryRepository.save(newMemory);

        // 3. 파일 업로드 및 MediaFile 저장
        if (files != null && !files.isEmpty()) {
            AtomicInteger displayOrder = new AtomicInteger(1);
            files.forEach(file -> {
                S3UploadDto s3Dto = s3Service.uploadMediaFile(file);
                MediaFileType fileType = getMediaFileType(file);
                MediaFile mediaFile = MediaFile.from(newMemory, s3Dto, file, fileType, displayOrder.getAndIncrement());
                mediaFileRepository.save(mediaFile);
            });
        }

        return newMemory.getMemoryId();
    }

    @Override
    public Slice<MemoryListResponseDto> getMemoryList(Long mapId, Long userId, Pageable pageable) {
        // 1. 권한 검증
        mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)
                .orElseThrow(() -> new MapException(NOT_MAP_MEMBER));

        // 2. 페이징 조회
        Slice<Memory> memorySlice = memoryRepository.findByMap_MapId(mapId, pageable);
        List<Memory> memories = memorySlice.getContent();

        // 3. 썸네일 일괄 조회
        List<Long> memoryIds = memories.stream().map(Memory::getMemoryId).collect(Collectors.toList());

        java.util.Map<Long, String> thumbnailMap = mediaFileRepository.findByMemoryIdIn(memoryIds).stream()
                .collect(Collectors.toMap(
                        mf -> mf.getMemory().getMemoryId(),
                        MediaFile::getFileUrl,
                        (existing, replacement) -> existing
                ));

        List<MemoryListResponseDto> content = memories.stream()
                .map(memory -> new MemoryListResponseDto(memory, thumbnailMap.get(memory.getMemoryId())))
                .collect(Collectors.toList());

        return new SliceImpl<>(content, pageable, memorySlice.hasNext());
    }

    @Override
    public List<MemoryMarkerResponseDto> getMemoryMarkers(Long mapId, Long userId) {
        // 1. 권한 검증
        mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)
                .orElseThrow(() -> new MapException(NOT_MAP_MEMBER));

        // 2. 좌표만 조회
        return memoryRepository.findAllByMap_MapId(mapId).stream()
                .map(MemoryMarkerResponseDto::new)
                .collect(Collectors.toList());
    }

    public MemoryDetailResponseDto getMemoryDetail(Long mapId, Long memoryId, Long userId) {
        Memory memory = validateAndGetMemory(mapId, memoryId, userId);

        List<MediaFileDto> mediaFiles = mediaFileRepository.findByMemoryIdOrderByDisplayOrder(memoryId)
                .stream()
                .map(MediaFileDto::new)
                .collect(Collectors.toList());

        return new MemoryDetailResponseDto(memory, mediaFiles);
    }

    @Transactional
    public void deleteMemory(Long mapId, Long memoryId, Long userId) {
        Memory memory = validateAndGetMemory(mapId, memoryId, userId);
        validateMemoryOwnership(memory, userId, NO_PERMISSION_TO_DELETE);

        // 파일 삭제
        List<MediaFile> filesToDelete = mediaFileRepository.findByMemoryId(memoryId);
        fileCleanupService.scheduleDeleteAll(filesToDelete.stream().map(MediaFile::getFileKey).toList());
        mediaFileRepository.deleteAll(filesToDelete);

        // Memory 삭제
        memoryRepository.delete(memory);
    }

    @Transactional
    public Long updateMemory(Long mapId, Long memoryId, UpdateMemoryRequestDto request,
                             List<MultipartFile> files, Long userId) {
        
        Memory memory = validateAndGetMemory(mapId, memoryId, userId);
        validateMemoryOwnership(memory, userId, NO_PERMISSION_TO_UPDATE);

        memory.update(request);

        // 기존 파일 삭제
        if (request.getDeleteFileIds() != null && !request.getDeleteFileIds().isEmpty()) {
            List<MediaFile> filesToDelete = mediaFileRepository.findAllByIdsAndMemoryId(request.getDeleteFileIds(), memoryId);

            if (filesToDelete.size() != request.getDeleteFileIds().size()) {
                throw new MemoryException(INVALID_MEDIA_FILE);
            }

            fileCleanupService.scheduleDeleteAll(filesToDelete.stream().map(MediaFile::getFileKey).toList());

            mediaFileRepository.deleteAll(filesToDelete);
        }

        // 새 파일 추가
        if (files != null && !files.isEmpty()) {
            List<MediaFile> existingFiles = mediaFileRepository.findByMemoryIdOrderByDisplayOrder(memoryId);

            int maxOrder = 0;
            for (MediaFile file : existingFiles) {
                if (file.getDisplayOrder() > maxOrder) {
                    maxOrder = file.getDisplayOrder();
                }
            }

            List<MediaFile> newFiles = new ArrayList<>();
            int displayOrder = maxOrder + 1;

            for (MultipartFile file : files) {
                S3UploadDto s3Dto = s3Service.uploadMediaFile(file);
                MediaFileType fileType = getMediaFileType(file);
                newFiles.add(MediaFile.from(memory, s3Dto, file, fileType, displayOrder++));
            }

            mediaFileRepository.saveAll(newFiles);
        }

        return memory.getMemoryId();
    }

    private MediaFileType getMediaFileType(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null) {
            throw new S3Exception(S3ErrorCode.INVALID_FILE_TYPE);
        }

        if (contentType.startsWith("image/")) {
            return MediaFileType.IMAGE;
        } else if (contentType.startsWith("video/")) {
            return MediaFileType.VIDEO;
        } else if (contentType.startsWith("audio/")) {
            return MediaFileType.AUDIO;
        } else {
            throw new S3Exception(S3ErrorCode.INVALID_FILE_TYPE);
        }
    }

    private Memory validateAndGetMemory(Long mapId, Long memoryId, Long userId) {
        // 맵 멤버 검증
        mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)
                .orElseThrow(() -> new MapException(NOT_MAP_MEMBER));

        // Memory 조회
        Memory memory = memoryRepository.findById(memoryId)
                .orElseThrow(() -> new MemoryException(MEMORY_NOT_FOUND));

        // Memory가 해당 Map에 속하는지 검증
        if (!memory.getMap().getMapId().equals(mapId)) {
            throw new MemoryException(MEMORY_NOT_FOUND);
        }

        return memory;
    }

    @Override
    public List<CalendarMemoryResponseDto> getCalendarMemories(int year, Long userId) {
        List<Memory> memories = memoryRepository.findAllByUserIdAndYear(userId, year);

        List<Long> memoryIds = memories.stream().map(Memory::getMemoryId).collect(Collectors.toList());

        if (memoryIds.isEmpty()) {
            return List.of();
        }

        java.util.Map<Long, String> thumbnailMap = mediaFileRepository.findByMemoryIdIn(memoryIds).stream()
                .collect(Collectors.toMap(
                        mf -> mf.getMemory().getMemoryId(),
                        MediaFile::getFileUrl,
                        (existing, replacement) -> existing
                ));

        return memories.stream()
                .map(memory -> new CalendarMemoryResponseDto(memory, thumbnailMap.get(memory.getMemoryId())))
                .collect(Collectors.toList());
    }

    private void validateMemoryOwnership(Memory memory, Long userId, MemoryErrorCode errorCode) {
        if (!memory.getUser().getUserId().equals(userId)) {
            throw new MemoryException(errorCode);
        }
    }

}

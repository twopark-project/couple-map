package com.couplemap.memory.service;

import com.couplemap.global.exception.exceptions.MapException;
import com.couplemap.global.exception.exceptions.UserException;
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
import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.dto.MemoryListResponseDto;
import com.couplemap.memory.repository.MemoryRepository;
import com.couplemap.user.domain.User;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

import static com.couplemap.global.exception.code.MapErrorCode.MAP_NOT_FOUND;
import static com.couplemap.global.exception.code.MapErrorCode.NO_INVITE_PERMISSION;
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
    private final MediaFileRepository mediaFileRepository;

    @Transactional
    @Override
    public Long createMemory(Long mapId, CreateMemoryRequestDto request, List<MultipartFile> files, Long userId) {
        // 1. 사용자 및 지도 멤버 정보 조회, 권한 확인
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        MapMember mapMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)
                .orElseThrow(() -> new MapException(NO_INVITE_PERMISSION)); // TODO: 더 적절한 에러 코드로 변경 필요

        if (mapMember.getMapMemberRole() != MapMemberRole.OWNER && mapMember.getMapMemberRole() != MapMemberRole.EDITOR) {
            throw new MapException(NO_INVITE_PERMISSION); // TODO: 더 적절한 에러 코드로 변경 필요
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
                S3UploadDto s3Dto = s3Service.uploadImageFile(file);
                MediaFileType fileType = getMediaFileType(file);
                MediaFile mediaFile = MediaFile.from(newMemory, s3Dto, file, fileType, displayOrder.getAndIncrement());
                mediaFileRepository.save(mediaFile);
            });
        }

        return newMemory.getMemoryId();
    }

    @Override
    public List<MemoryListResponseDto> getMemoryList(Long mapId, Long userId) {
        // 1. 권한 검증
        mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)
                .orElseThrow(() -> new MapException(NO_INVITE_PERMISSION)); // TODO: 더 적절한 에러 코드로 변경 필요

        // 2. 해당 지도의 모든 Memory 조회
        List<Memory> memories = memoryRepository.findAllByMap_MapId(mapId);

        // 3. DTO로 변환
        return memories.stream()
                .map(MemoryListResponseDto::new)
                .collect(Collectors.toList());
    }

    private MediaFileType getMediaFileType(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null) {
            throw new IllegalArgumentException("파일의 타입을 알 수 없습니다.");
        }

        if (contentType.startsWith("image/")) {
            return MediaFileType.IMAGE;
        } else if (contentType.startsWith("video/")) {
            return MediaFileType.VIDEO;
        } else if (contentType.startsWith("audio/")) {
            return MediaFileType.AUDIO;
        } else {
            throw new IllegalArgumentException("지원하지 않는 파일 타입입니다: " + contentType);
        }
    }
}

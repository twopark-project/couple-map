package com.couplemap.map.service;

import com.couplemap.global.exception.exceptions.MapException;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.global.s3.S3Service;
import com.couplemap.global.s3.S3UploadDto;
import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.dto.*;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.user.domain.User;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

import static com.couplemap.global.exception.code.MapErrorCode.*;
import static com.couplemap.global.exception.code.UserErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MapServiceImpl implements MapService {

    private final MapRepository mapRepository;
    private final MapMemberRepository mapMemberRepository;
    private final UserRepository userRepository;
    private final S3Service s3Service;

    @Transactional
    @Override
    public Long createMap(CreateMapRequestDto request, MultipartFile backgroundImage, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        if (mapMemberRepository.existsByUserIdAndMapName(userId, request.getMapName())) {
            throw new MapException(MAP_NAME_DUPLICATED);
        }

        Map newMap = Map.from(request.getMapName(), request.getDescription());

        if (backgroundImage != null && !backgroundImage.isEmpty()) {
            S3UploadDto uploadResult = s3Service.uploadImageFile(backgroundImage);
            newMap.updateBackground(uploadResult.getUrl(), uploadResult.getKey());
        }

        mapRepository.save(newMap);

        MapMember mapMember = MapMember.from(newMap, user, MapMemberRole.OWNER);
        mapMemberRepository.save(mapMember);

        return newMap.getMapId();
    }

    @Override
    @Transactional
    public void deleteMap(Long mapId, Long userId) {
        MapMember mapMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)
                .orElseThrow(() -> new MapException(NOT_MAP_MEMBER));

        if (mapMember.getMapMemberRole() != MapMemberRole.OWNER) {
            throw new MapException(NO_DELETE_PERMISSION);
        }

        Map dMap = mapMember.getMap();
        mapMemberRepository.deleteAllByMap(dMap);
        mapRepository.delete(dMap);
    }

    @Override
    @Transactional
    public void updateMap(Long mapId, UpdateMapRequestDto request, MultipartFile backgroundImage, Long userId) {
        Map map = mapRepository.findById(mapId)
                .orElseThrow(() -> new MapException(MAP_NOT_FOUND));

        MapMember mapMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, userId)
                .orElseThrow(() -> new MapException(NOT_MAP_MEMBER));

        if (mapMember.getMapMemberRole() != MapMemberRole.OWNER) {
            throw new MapException(NO_UPDATE_PERMISSION);
        }

        if (mapMemberRepository.existsByUserIdAndMapNameExcludingMapId(userId, request.getMapName(), mapId)) {
            throw new MapException(MAP_NAME_DUPLICATED);
        }

        map.update(request.getMapName(), request.getDescription());

        if (backgroundImage != null && !backgroundImage.isEmpty()) {
            // 기존 배경 이미지 삭제
            if (map.getBackgroundKey() != null) {
                s3Service.deleteFile(map.getBackgroundKey());
            }
            S3UploadDto uploadResult = s3Service.uploadImageFile(backgroundImage);
            map.updateBackground(uploadResult.getUrl(), uploadResult.getKey());
        }
    }

    @Override
    public List<MapListDto> getMapList(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));
        return mapMemberRepository.findAllByUser(user).stream()
                .filter(mapMember -> mapMember.getMapMemberRole() != MapMemberRole.PENDING)
                .map(mapMember -> {
                    long memberCount = mapMemberRepository.countByMap_MapIdAndMapMemberRoleNot(
                            mapMember.getMap().getMapId(), MapMemberRole.PENDING);
                    return MapListDto.from(mapMember, memberCount);
                })
                .collect(Collectors.toList());
    }

    @Transactional
    @Override
    public void inviteFriend(Long mapId, InviteFriendRequestDto request, Long userId) {
        User inviter = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        MapMember invitingMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, inviter.getUserId())
                .orElseThrow(() -> new MapException(NOT_MAP_MEMBER));

        if (invitingMember.getMapMemberRole() != MapMemberRole.OWNER && invitingMember.getMapMemberRole() != MapMemberRole.EDITOR) {
            throw new MapException(NO_INVITE_PERMISSION);
        }

        User friendToInvite = userRepository.findByFriendCode(request.getFriendCode())
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, friendToInvite.getUserId()).ifPresent(m -> {
            throw new MapException(ALREADY_MAP_MEMBER);
        });

        Map map = invitingMember.getMap();
        MapMember newMember = MapMember.from(map, friendToInvite, inviter, MapMemberRole.PENDING);
        mapMemberRepository.save(newMember);
    }

    @Transactional
    @Override
    public void acceptInvitation(Long mapMemberId, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        MapMember mapMember = mapMemberRepository.findById(mapMemberId)
                .orElseThrow(() -> new MapException(INVITATION_NOT_FOUND));

        if (!mapMember.isInvitedUser(user)) {
            throw new MapException(NOT_INVITED_USER);
        }

        if (!mapMember.isPending()) {
            throw new MapException(INVITATION_NOT_FOUND);
        }

        mapMember.accept();
    }

    @Transactional
    @Override
    public void rejectInvitation(Long mapMemberId, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));

        MapMember mapMember = mapMemberRepository.findById(mapMemberId)
                .orElseThrow(() -> new MapException(INVITATION_NOT_FOUND));

        if (!mapMember.isInvitedUser(user)) {
            throw new MapException(NOT_INVITED_USER);
        }

        if (!mapMember.isPending()) {
            throw new MapException(INVITATION_NOT_FOUND);
        }

        mapMemberRepository.delete(mapMember);
    }

    @Override
    public List<MapInvitationDto> getInvitationList(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(USER_NOT_FOUND));
        return mapMemberRepository.findAllByUserAndMapMemberRole(user, MapMemberRole.PENDING).stream()
                .map(MapInvitationDto::from)
                .collect(Collectors.toList());
    }
}

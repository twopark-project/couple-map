package com.couplemap.map.service;

import com.couplemap.map.dto.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface MapService {
    Long createMap(CreateMapRequestDto request, MultipartFile backgroundImage, Long userId);

    List<MapListDto> getMapList(Long userId);

    void inviteFriend(Long mapId, InviteFriendRequestDto request, Long userId);

    void acceptInvitation(Long mapMemberId, Long userId);

    void rejectInvitation(Long mapMemberId, Long userId);

    List<MapInvitationDto> getInvitationList(Long userId);

    void deleteMap(Long mapId, Long userId);

    void updateMap(Long mapId, UpdateMapRequestDto request, MultipartFile backgroundImage, Long userId);

    List<MapMemberDto> getMapMembers(Long mapId, Long userId);
}

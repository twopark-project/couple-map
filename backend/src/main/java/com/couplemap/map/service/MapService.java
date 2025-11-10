package com.couplemap.map.service;

import com.couplemap.map.dto.CreateMapRequestDto;
import com.couplemap.map.dto.InviteFriendRequestDto;
import com.couplemap.map.dto.MapInvitationDto;
import com.couplemap.map.dto.MapListDto;

import java.util.List;

public interface MapService {
    Long createMap(CreateMapRequestDto request, Long userId);

    List<MapListDto> getMapList(Long userId);

    void inviteFriend(Long mapId, InviteFriendRequestDto request, Long userId);

    void acceptInvitation(Long mapMemberId, Long userId);

    void rejectInvitation(Long mapMemberId, Long userId);

    List<MapInvitationDto> getInvitationList(Long userId);
}

package com.couplemap.map.service;

import com.couplemap.global.exception.exceptions.MapException;
import com.couplemap.global.exception.exceptions.UserException;
import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.dto.CreateMapRequest;
import com.couplemap.map.dto.InviteFriendRequest;
import com.couplemap.map.dto.MapInvitationDto;
import com.couplemap.map.dto.MapListDto;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.user.domain.User;
import com.couplemap.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Transactional
    @Override
    public Long createMap(CreateMapRequest request, User user) {
        Map newMap = Map.from(request.getMapName(), request.getDescription());
        mapRepository.save(newMap);

        MapMember mapMember = MapMember.from(newMap, user, MapMemberRole.OWNER);
        mapMemberRepository.save(mapMember);

        return newMap.getMapId();
    }

    @Override
    public List<MapListDto> getMapList(User user) {
        return mapMemberRepository.findAllByUser(user).stream()
                .map(mapMember -> new MapListDto(
                        mapMember.getMap().getMapId(),
                        mapMember.getMap().getMapName(),
                        mapMember.getMap().getDescription(),
                        mapMember.getMapMemberRole()
                ))
                .collect(Collectors.toList());
    }

    @Transactional
    @Override
    public void inviteFriend(Long mapId, InviteFriendRequest request, User user) {
        MapMember invitingMember = mapMemberRepository.findByMap_MapIdAndUser_UserId(mapId, user.getUserId())
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
        MapMember newMember = MapMember.from(map, friendToInvite, MapMemberRole.PENDING);
        mapMemberRepository.save(newMember);
    }

    @Transactional
    @Override
    public void acceptInvitation(Long mapMemberId, User user) {
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
    public void rejectInvitation(Long mapMemberId, User user) {
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
    public List<MapInvitationDto> getInvitationList(User user) {
        return mapMemberRepository.findAllByUserAndMapMemberRole(user, MapMemberRole.PENDING).stream()
                .map(mapMember -> new MapInvitationDto(
                        mapMember.getMapMemberId(),
                        mapMember.getMap().getMapName()
                ))
                .collect(Collectors.toList());
    }
}

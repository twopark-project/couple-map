package com.couplemap.map.service;

import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.dto.CreateMapRequest;
import com.couplemap.map.dto.MapListDto;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MapServiceImpl implements MapService {

    private final MapRepository mapRepository;
    private final MapMemberRepository mapMemberRepository;

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
}

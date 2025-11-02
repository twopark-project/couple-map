package com.couplemap.map.service;

import com.couplemap.map.dto.CreateMapRequest;
import com.couplemap.map.dto.MapListDto;
import com.couplemap.user.domain.User;

import java.util.List;

public interface MapService {
    Long createMap(CreateMapRequest request, User user);
    List<MapListDto> getMapList(User user);
}

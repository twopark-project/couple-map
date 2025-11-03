package com.couplemap.map.controller;

import com.couplemap.global.response.ApiResponse;
import com.couplemap.map.dto.CreateMapRequest;
import com.couplemap.map.dto.InviteFriendRequest;
import com.couplemap.map.dto.MapInvitationDto;
import com.couplemap.map.dto.MapListDto;
import com.couplemap.map.service.MapService;
import com.couplemap.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/map")
public class MapController {

    private final MapService mapService;

    @PostMapping
    public ResponseEntity<ApiResponse<Long>> createMap(@RequestBody CreateMapRequest request, @AuthenticationPrincipal User user) {
        Long mapId = mapService.createMap(request, user);
        return ResponseEntity.created(URI.create("/api/map/" + mapId))
                .body(ApiResponse.success(mapId, "지도가 성공적으로 생성되었습니다."));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<MapListDto>>> getMapList(@AuthenticationPrincipal User user) {
        List<MapListDto> mapList = mapService.getMapList(user);
        return ResponseEntity.ok(ApiResponse.success(mapList, "지도 목록 조회가 완료되었습니다."));
    }

    @PostMapping("/{mapId}/invite")
    public ResponseEntity<ApiResponse<Void>> inviteFriend(@PathVariable Long mapId,
                                                        @RequestBody InviteFriendRequest request,
                                                        @AuthenticationPrincipal User user) {
        mapService.inviteFriend(mapId, request, user);
        return ResponseEntity.ok(ApiResponse.success("지도에 친구를 초대했습니다."));
    }

    @PostMapping("/member/{mapMemberId}/accept")
    public ResponseEntity<ApiResponse<Void>> acceptInvitation(@PathVariable Long mapMemberId, @AuthenticationPrincipal User user) {
        mapService.acceptInvitation(mapMemberId, user);
        return ResponseEntity.ok(ApiResponse.success("초대를 수락했습니다."));
    }

    @PostMapping("/member/{mapMemberId}/reject")
    public ResponseEntity<ApiResponse<Void>> rejectInvitation(@PathVariable Long mapMemberId, @AuthenticationPrincipal User user) {
        mapService.rejectInvitation(mapMemberId, user);
        return ResponseEntity.ok(ApiResponse.success("초대를 거절했습니다."));
    }

    @GetMapping("/invitations")
    public ResponseEntity<ApiResponse<List<MapInvitationDto>>> getInvitationList(@AuthenticationPrincipal User user) {
        List<MapInvitationDto> invitationList = mapService.getInvitationList(user);
        return ResponseEntity.ok(ApiResponse.success(invitationList, "받은 초대 목록 조회가 완료되었습니다."));
    }
}

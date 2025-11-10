package com.couplemap.friend.controller;

import com.couplemap.friend.dto.FriendListResponseDto;
import com.couplemap.friend.dto.FriendPendingListResponseDto;
import com.couplemap.friend.dto.FriendRequestResponseDto;
import com.couplemap.friend.dto.SendFriendRequestDto;
import com.couplemap.friend.service.FriendService;
import com.couplemap.global.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RequestMapping("/api/friend")
@RequiredArgsConstructor
@RestController
public class FriendController {

    private final FriendService friendService;

    /*
    친구 요청 전송
     */
    @PostMapping("/request")
    public ResponseEntity<ApiResponse<FriendRequestResponseDto>> request(@RequestBody SendFriendRequestDto requestDto,
                                                                         @AuthenticationPrincipal(expression = "userId") Long userId) {
        FriendRequestResponseDto responseDto = friendService.sendFriendRequest(requestDto, userId);
        return ResponseEntity.ok(ApiResponse.success(responseDto, "친구 요청이 전송되었습니다."));
    }

    /*
    친구 목록 확인
     */
    @GetMapping("/list")
    public ResponseEntity<ApiResponse<FriendListResponseDto>> list(@AuthenticationPrincipal(expression = "userId") Long userId) {
        FriendListResponseDto listDto = friendService.getFriendList(userId);
        return ResponseEntity.ok(ApiResponse.success(listDto));
    }

    /*
     친구 요청 온 목록 확인 (PENDING)
     */
    @GetMapping("/list/pending")
    public ResponseEntity<ApiResponse<FriendPendingListResponseDto>> pendingList(@AuthenticationPrincipal(expression = "userId") Long userId) {
        FriendPendingListResponseDto listDto = friendService.getFriendPendingList(userId);
        return ResponseEntity.ok(ApiResponse.success(listDto));
    }

    /*
    친구 요청 거절
     */
    @PostMapping("/{friendshipId}/reject")
    public ResponseEntity<ApiResponse<Void>> reject(@PathVariable Long friendshipId,
                                                    @AuthenticationPrincipal(expression = "userId") Long userId) {
        friendService.reject(friendshipId,userId);
        return ResponseEntity.ok(ApiResponse.success("친구 요청이 거절되었습니다."));
    }

    /*
    친구 요청 수락
     */
    @PostMapping("/{friendshipId}/accept")
    public ResponseEntity<ApiResponse<Void>> accept(@PathVariable Long friendshipId,
                                                    @AuthenticationPrincipal(expression = "userId") Long userId) {
        friendService.accept(friendshipId,userId);
        return ResponseEntity.ok(ApiResponse.success("친구 요청이 수락되었습니다."));
    }
}

package com.couplemap.friend.controller;

import com.couplemap.friend.dto.FriendRequestResponseDto;
import com.couplemap.friend.dto.SendFriendRequestDto;
import com.couplemap.friend.service.FriendService;
import com.couplemap.global.response.ApiResponse;
import com.couplemap.login.dto.CustomOAuth2User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
                                                                         @AuthenticationPrincipal CustomOAuth2User customOAuth2User) {
        Long requesterId = customOAuth2User.getUserId();
        FriendRequestResponseDto responseDto = friendService.sendFriendRequest(requestDto, requesterId);
        return ResponseEntity.ok(ApiResponse.success(responseDto, "친구 요청이 전송되었습니다."));
    }
}

package com.couplemap.login.controller;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class check {

    @Value("${KAKAO_ID}")
    private String kakaoId;

    @PostConstruct
    public void check() {
        // 애플리케이션 시작 시 콘솔에 이 로그가 찍힙니다.
        System.out.println("=========================================");
        System.out.println("### KAKAO_ID: " + kakaoId + " ###");
        System.out.println("=========================================");
    }
}
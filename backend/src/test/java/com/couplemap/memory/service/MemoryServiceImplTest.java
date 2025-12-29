package com.couplemap.memory.service;

import com.couplemap.global.exception.exceptions.MemoryException;
import com.couplemap.global.s3.S3Service;
import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.memory.domain.Memory;
import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.dto.UpdateMemoryRequestDto;
import com.couplemap.memory.repository.MemoryRepository;
import com.couplemap.user.domain.User;
import com.couplemap.user.domain.UserRole;
import com.couplemap.user.repository.UserRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
class MemoryServiceImplTest {

    @Autowired
    private MemoryService memoryService;

    @Autowired
    private MemoryRepository memoryRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MapRepository mapRepository;

    @Autowired
    private MapMemberRepository mapMemberRepository;

    @Autowired
    private S3Service s3Service;

    private List<String> uploadedKeys = new ArrayList<>();
    private User testUser;
    private User anotherUser;
    private Map testMap;
    private Memory testMemory;
    private MockMultipartFile testFile;

    @BeforeEach
    void setUp() throws IOException {
        // 테스트 유저 생성
        testUser = User.builder()
                .email("test@example.com")
                .name("테스트유저")
                .friendCode("TEST1234")
                .providerId("TEST12341")
                .loginType("KAKAO")
                .role(UserRole.USER)
                .build();
        testUser = userRepository.save(testUser);

        anotherUser = User.builder()
                .email("another@example.com")
                .name("다른유저")
                .friendCode("TEST5678")
                .providerId("TEST56781")
                .loginType("KAKAO")
                .role(UserRole.USER)
                .build();
        anotherUser = userRepository.save(anotherUser);

        // 테스트 맵 생성

        testMap = Map.from("테스트맵", "테스트 설명");
        testMap = mapRepository.save(testMap);

        // 맵 멤버 등록 (testUser는 OWNER)
        MapMember mapMember1 = MapMember.from(testMap, testUser, MapMemberRole.OWNER);
        mapMemberRepository.save(mapMember1);

        // anotherUser도 멤버로 등록 (EDITOR)
        MapMember mapMember2 = MapMember.from(testMap, anotherUser, MapMemberRole.EDITOR);
        mapMemberRepository.save(mapMember2);

        CreateMemoryRequestDto memoryRequest = new CreateMemoryRequestDto(
                "테스트 추억",
                "테스트 내용",
                "테스트 장소",
                LocalDate.of(2024, 1, 1),
                new BigDecimal("37.5665"),
                new BigDecimal("126.9780")
        );

        testMemory = Memory.from(memoryRequest, testMap, testUser);
        testMemory = memoryRepository.save(testMemory);

        File file = new File("src/test/resources/test.png");
        if (file.exists()) {
            FileInputStream input = new FileInputStream(file);
            testFile = new MockMultipartFile(
                    "file", "test.png", "image/png", input
            );
        }
    }

    @AfterEach
    void cleanup() {
        // S3 파일 정리
        for (String key : uploadedKeys) {
            try {
                s3Service.deleteFile(key);
            } catch (Exception e) {
            }
        }
        uploadedKeys.clear();

        // DB 정리
        try {
            if (testMemory != null) memoryRepository.delete(testMemory);
        } catch (Exception e) {
        }
        try {
            mapMemberRepository.deleteAll();
        } catch (Exception e) {
        }
        try {
            if (testMap != null) mapRepository.delete(testMap);
        } catch (Exception e) {
        }
        try {
            if (testUser != null) userRepository.delete(testUser);
            if (anotherUser != null) userRepository.delete(anotherUser);
        } catch (Exception e) {
        }
    }

    @Test
    @DisplayName("추억 생성 성공")
    void createMemory_Success() {
        // given
        CreateMemoryRequestDto request = new CreateMemoryRequestDto(
                "새로운 추억",
                "새로운 내용",
                "새로운 장소",
                LocalDate.of(2024, 3, 15),
                new BigDecimal("37.1234"),
                new BigDecimal("127.5678")
        );

        // when
        Long createdMemoryId = memoryService.createMemory(testMap.getMapId(), request, null, testUser.getUserId());

        // then
        assertThat(createdMemoryId).isNotNull();
        Memory created = memoryRepository.findById(createdMemoryId).orElseThrow();
        assertThat(created.getTitle()).isEqualTo("새로운 추억");
        assertThat(created.getContent()).isEqualTo("새로운 내용");
        assertThat(created.getPlaceName()).isEqualTo("새로운 장소");
        assertThat(created.getUser().getUserId()).isEqualTo(testUser.getUserId());
    }

    @Test
    @DisplayName("추억 목록 조회 성공")
    void getMemoryList_Success() {
        // given - 추가 추억 생성
        CreateMemoryRequestDto additionalRequest = new CreateMemoryRequestDto(
                "두번째 추억",
                "두번째 내용",
                "두번째 장소",
                LocalDate.of(2024, 4, 1),
                new BigDecimal("36.5555"),
                new BigDecimal("128.1111")
        );
        memoryService.createMemory(testMap.getMapId(), additionalRequest, null, testUser.getUserId());

        // when
        var memoryList = memoryService.getMemoryList(testMap.getMapId(), testUser.getUserId());

        // then
        assertThat(memoryList).hasSize(2);
        assertThat(memoryList).extracting("title")
                .containsExactlyInAnyOrder("테스트 추억", "두번째 추억");
    }

    @Test
    @DisplayName("추억 삭제 성공 - 작성자 본인이 삭제")
    void deleteMemory_Success() {
        // when
        memoryService.deleteMemory(testMap.getMapId(), testMemory.getMemoryId(), testUser.getUserId());

        // then
        assertThat(memoryRepository.findById(testMemory.getMemoryId())).isEmpty();
    }

    @Test
    @DisplayName("추억 삭제 실패 - 작성자가 아닌 사용자")
    void deleteMemory_NotAuthor() {
        // when & then
        assertThatThrownBy(() ->
                memoryService.deleteMemory(testMap.getMapId(), testMemory.getMemoryId(), anotherUser.getUserId())
        )
                .isInstanceOf(MemoryException.class)
                .hasMessageContaining("삭제할 권한이 없습니다");
    }

    @Test
    @DisplayName("추억 삭제 실패 - 존재하지 않는 추억")
    void deleteMemory_NotFound() {
        // when & then
        assertThatThrownBy(() ->
                memoryService.deleteMemory(testMap.getMapId(), 99999L, testUser.getUserId())
        )
                .isInstanceOf(MemoryException.class)
                .hasMessageContaining("존재하지 않는 추억");
    }

    @Test
    @DisplayName("추억 수정 성공 - 필드만 수정")
    void updateMemory_Success_OnlyFields() {
        // given
        UpdateMemoryRequestDto request = new UpdateMemoryRequestDto(
                "수정된 제목",
                "수정된 내용",
                "수정된 장소",
                LocalDate.of(2024, 2, 1),
                null
        );

        // when
        memoryService.updateMemory(testMap.getMapId(), testMemory.getMemoryId(), request, null, testUser.getUserId());

        // then
        Memory updated = memoryRepository.findById(testMemory.getMemoryId()).orElseThrow();
        assertThat(updated.getTitle()).isEqualTo("수정된 제목");
        assertThat(updated.getContent()).isEqualTo("수정된 내용");
        assertThat(updated.getPlaceName()).isEqualTo("수정된 장소");
    }

    @Test
    @DisplayName("추억 수정 실패 - 작성자가 아닌 사용자")
    void updateMemory_NotAuthor() {
        // given
        UpdateMemoryRequestDto request = new UpdateMemoryRequestDto(
                "수정 시도",
                null,
                "장소",
                LocalDate.of(2024, 1, 1),
                null
        );

        // when & then
        assertThatThrownBy(() ->
                memoryService.updateMemory(testMap.getMapId(), testMemory.getMemoryId(), request, null, anotherUser.getUserId())
        )
                .isInstanceOf(MemoryException.class)
                .hasMessageContaining("수정할 권한이 없습니다");
    }
}

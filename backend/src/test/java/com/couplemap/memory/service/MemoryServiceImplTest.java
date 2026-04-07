package com.couplemap.memory.service;

import com.couplemap.friend.repository.FriendshipRepository;
import com.couplemap.global.exception.exceptions.MemoryException;
import com.couplemap.global.s3.S3Service;
import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.map.repository.MapMemberRepository;
import com.couplemap.map.repository.MapRepository;
import com.couplemap.mediafile.repository.MediaFileRepository;
import com.couplemap.memory.domain.Memory;
import com.couplemap.memory.dto.CalendarMemoryResponseDto;
import com.couplemap.memory.dto.CreateMemoryRequestDto;
import com.couplemap.memory.dto.MemoryDetailResponseDto;
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
import org.springframework.web.multipart.MultipartFile;

import org.springframework.data.domain.PageRequest;

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

    @Autowired
    private MediaFileRepository mediaFileRepository;

    @Autowired
    private FriendshipRepository friendshipRepository;

    private List<String> uploadedKeys = new ArrayList<>();
    private User testUser;
    private User anotherUser;
    private User notMemberUser;
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

        testMap = Map.from("테스트맵", "테스트 설명", "Solo");
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
                null,
                LocalDate.of(2024, 1, 1),
                new BigDecimal("37.5665"),
                new BigDecimal("126.9780"),
                null
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

        // DB 정리 (FK 순서: friendship → mediaFile → memory → mapMember → map → user)
        friendshipRepository.deleteAll();
        mediaFileRepository.deleteAll();
        memoryRepository.deleteAll();
        mapMemberRepository.deleteAll();
        mapRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("추억 생성 성공")
    void createMemory_Success() {
        // given
        CreateMemoryRequestDto request = new CreateMemoryRequestDto(
                "새로운 추억",
                "새로운 내용",
                "새로운 장소",
                null,
                LocalDate.of(2024, 3, 15),
                new BigDecimal("37.1234"),
                new BigDecimal("127.5678"),
                null
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
                null,
                LocalDate.of(2024, 4, 1),
                new BigDecimal("36.5555"),
                new BigDecimal("128.1111"),
                null
        );
        memoryService.createMemory(testMap.getMapId(), additionalRequest, null, testUser.getUserId());

        // when
        var memoryList = memoryService.getMemoryList(testMap.getMapId(), testUser.getUserId(), PageRequest.of(0, 10));

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
                null,
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
                null,
                null
        );

        // when & then
        assertThatThrownBy(() ->
                memoryService.updateMemory(testMap.getMapId(), testMemory.getMemoryId(), request, null, anotherUser.getUserId())
        )
                .isInstanceOf(MemoryException.class)
                .hasMessageContaining("수정할 권한이 없습니다");
    }

    @Test
    @DisplayName("추억 상세 조회 성공")
    void getMemoryDetail_Success() {
        // when
        MemoryDetailResponseDto result = memoryService.getMemoryDetail(
                testMap.getMapId(),
                testMemory.getMemoryId(),
                testUser.getUserId()
        );

        // then
        assertThat(result).isNotNull();
        assertThat(result.getMemoryId()).isEqualTo(testMemory.getMemoryId());
        assertThat(result.getTitle()).isEqualTo("테스트 추억");
        assertThat(result.getContent()).isEqualTo("테스트 내용");
        assertThat(result.getPlaceName()).isEqualTo("테스트 장소");
        assertThat(result.getMemoryDate()).isEqualTo(LocalDate.of(2024, 1, 1));
        assertThat(result.getLatitude()).isEqualByComparingTo(new BigDecimal("37.5665"));
        assertThat(result.getLongitude()).isEqualByComparingTo(new BigDecimal("126.9780"));
        assertThat(result.getCreatedAt()).isNotNull();
        assertThat(result.getUpdatedAt()).isNotNull();
        assertThat(result.getMediaFiles()).isEmpty();
    }

    @Test
    @DisplayName("추억 상세 조회 성공 - 미디어 파일 포함")
    void getMemoryDetail_WithMediaFiles() {
        // given - 파일과 함께 추억 생성
        CreateMemoryRequestDto request = new CreateMemoryRequestDto(
                "파일 포함 추억",
                "파일 포함 내용",
                "파일 포함 장소",
                null,
                LocalDate.of(2024, 5, 1),
                new BigDecimal("37.1234"),
                new BigDecimal("127.5678"),
                null
        );

        List<MultipartFile> files = new ArrayList<>();
        if (testFile != null) {
            files.add(testFile);
        }

        Long memoryId = memoryService.createMemory(testMap.getMapId(), request, files, testUser.getUserId());

        // when
        MemoryDetailResponseDto result = memoryService.getMemoryDetail(
                testMap.getMapId(),
                memoryId,
                testUser.getUserId()
        );

        // then
        assertThat(result).isNotNull();
        assertThat(result.getTitle()).isEqualTo("파일 포함 추억");
        if (testFile != null) {
            assertThat(result.getMediaFiles()).hasSize(1);
            assertThat(result.getMediaFiles().get(0).getOriginalFilename()).isEqualTo("test.png");
            assertThat(result.getMediaFiles().get(0).getDisplayOrder()).isEqualTo(1);
        }
    }

    @Test
    @DisplayName("추억 상세 조회 성공 - 다른 멤버도 조회 가능")
    void getMemoryDetail_AnotherMember() {
        // when - anotherUser(EDITOR)가 testUser가 작성한 추억 조회
        MemoryDetailResponseDto result = memoryService.getMemoryDetail(
                testMap.getMapId(),
                testMemory.getMemoryId(),
                anotherUser.getUserId()
        );

        // then - 조회는 모든 멤버가 가능
        assertThat(result).isNotNull();
        assertThat(result.getMemoryId()).isEqualTo(testMemory.getMemoryId());
        assertThat(result.getTitle()).isEqualTo("테스트 추억");
    }

    @Test
    @DisplayName("캘린더 추억 조회 성공 - 해당 연도 추억만 반환")
    void getCalendarMemories_Success() {
        // given - 2024년 추억 추가
        CreateMemoryRequestDto request2024 = new CreateMemoryRequestDto(
                "2024 추억",
                "2024 내용",
                "2024 장소",
                null,
                LocalDate.of(2024, 6, 15),
                new BigDecimal("37.1234"),
                new BigDecimal("127.5678"),
                null
        );
        memoryService.createMemory(testMap.getMapId(), request2024, null, testUser.getUserId());

        // 2025년 추억 추가
        CreateMemoryRequestDto request2025 = new CreateMemoryRequestDto(
                "2025 추억",
                "2025 내용",
                "2025 장소",
                null,
                LocalDate.of(2025, 3, 10),
                new BigDecimal("37.5555"),
                new BigDecimal("126.9999"),
                null
        );
        memoryService.createMemory(testMap.getMapId(), request2025, null, testUser.getUserId());

        // when - 2024년 조회 (setUp의 testMemory도 2024-01-01)
        List<CalendarMemoryResponseDto> result = memoryService.getCalendarMemories(2024, testUser.getUserId());

        // then
        assertThat(result).hasSize(2);
        assertThat(result).extracting("title")
                .containsExactlyInAnyOrder("테스트 추억", "2024 추억");
        assertThat(result).allSatisfy(dto -> {
            assertThat(dto.getMemoryDate().getYear()).isEqualTo(2024);
            assertThat(dto.getMapId()).isEqualTo(testMap.getMapId());
        });
    }

    @Test
    @DisplayName("캘린더 추억 조회 - 해당 연도에 추억이 없으면 빈 리스트 반환")
    void getCalendarMemories_EmptyYear() {
        // when - 2030년 조회
        List<CalendarMemoryResponseDto> result = memoryService.getCalendarMemories(2030, testUser.getUserId());

        // then
        assertThat(result).isEmpty();
    }

    @Test
    @DisplayName("캘린더 추억 조회 - 여러 지도의 추억을 모두 반환")
    void getCalendarMemories_MultipleMapMemories() {
        // given - 두 번째 맵 생성
        Map secondMap = Map.from("두번째맵", "두번째 설명", "Friends");
        secondMap = mapRepository.save(secondMap);
        MapMember secondMapMember = MapMember.from(secondMap, testUser, MapMemberRole.OWNER);
        mapMemberRepository.save(secondMapMember);

        CreateMemoryRequestDto request = new CreateMemoryRequestDto(
                "두번째맵 추억",
                "두번째맵 내용",
                "두번째맵 장소",
                null,
                LocalDate.of(2024, 7, 20),
                new BigDecimal("35.1234"),
                new BigDecimal("129.5678"),
                null
        );
        memoryService.createMemory(secondMap.getMapId(), request, null, testUser.getUserId());

        // when - 2024년 조회
        List<CalendarMemoryResponseDto> result = memoryService.getCalendarMemories(2024, testUser.getUserId());

        // then - testMap(2024-01-01) + secondMap(2024-07-20)
        assertThat(result).hasSize(2);
        assertThat(result).extracting("title")
                .containsExactlyInAnyOrder("테스트 추억", "두번째맵 추억");
    }

    @Test
    @DisplayName("캘린더 추억 조회 - PENDING 멤버는 해당 맵 추억 조회 불가")
    void getCalendarMemories_PendingMemberExcluded() {
        // given - notMemberUser를 PENDING으로 추가
        User pendingUser = User.builder()
                .email("pending@example.com")
                .name("펜딩유저")
                .friendCode("PEND1234")
                .providerId("PEND12341")
                .loginType("KAKAO")
                .role(UserRole.USER)
                .build();
        pendingUser = userRepository.save(pendingUser);

        MapMember pendingMember = MapMember.from(testMap, pendingUser, MapMemberRole.PENDING);
        mapMemberRepository.save(pendingMember);

        // when
        List<CalendarMemoryResponseDto> result = memoryService.getCalendarMemories(2024, pendingUser.getUserId());

        // then - PENDING 멤버는 추억 조회 불가
        assertThat(result).isEmpty();
    }
}

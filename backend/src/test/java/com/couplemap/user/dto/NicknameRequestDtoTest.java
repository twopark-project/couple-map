package com.couplemap.user.dto;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

@DisplayName("SetNicknameRequestDto Validation 테스트")
class NicknameRequestDtoTest {

    private static Validator validator;

    @BeforeAll
    static void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    @DisplayName("유효한 닉네임 - 한글")
    void validNickname_Korean() {
        NicknameRequestDto dto = createDto("커플맵");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).isEmpty();
    }

    @Test
    @DisplayName("유효한 닉네임 - 영문")
    void validNickname_English() {
        NicknameRequestDto dto = createDto("CoupleMap");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).isEmpty();
    }

    @Test
    @DisplayName("유효한 닉네임 - 숫자")
    void validNickname_Number() {
        NicknameRequestDto dto = createDto("유저123");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).isEmpty();
    }

    @Test
    @DisplayName("유효한 닉네임 - 한글+영문+숫자 조합")
    void validNickname_Mixed() {
        NicknameRequestDto dto = createDto("커플Map123");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).isEmpty();
    }

    @Test
    @DisplayName("유효한 닉네임 - 최소 길이 (2자)")
    void validNickname_MinLength() {
        NicknameRequestDto dto = createDto("닉네");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).isEmpty();
    }

    @Test
    @DisplayName("유효한 닉네임 - 최대 길이 (10자)")
    void validNickname_MaxLength() {
        NicknameRequestDto dto = createDto("1234567890");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).isEmpty();
    }

    @Test
    @DisplayName("닉네임 null - 검증 실패")
    void invalidNickname_Null() {
        NicknameRequestDto dto = createDto(null);

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSize(1);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .contains("닉네임은 필수입니다.");
    }

    @Test
    @DisplayName("닉네임 빈 문자열 - 검증 실패")
    void invalidNickname_Empty() {
        NicknameRequestDto dto = createDto("");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSize(3);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .contains("닉네임은 필수입니다.");
    }

    @Test
    @DisplayName("닉네임 공백만 - 검증 실패")
    void invalidNickname_Blank() {
        NicknameRequestDto dto = createDto("   ");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSizeGreaterThanOrEqualTo(1);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .contains("닉네임은 필수입니다.");
    }

    @Test
    @DisplayName("닉네임 1글자 - 검증 실패 (최소 길이)")
    void invalidNickname_TooShort() {
        NicknameRequestDto dto = createDto("닉");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSize(1);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .contains("닉네임은 2자 이상 10자 이하로 입력해주세요.");
    }

    @Test
    @DisplayName("닉네임 11글자 - 검증 실패 (최대 길이)")
    void invalidNickname_TooLong() {
        NicknameRequestDto dto = createDto("12345678901");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSize(1);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .contains("닉네임은 2자 이상 10자 이하로 입력해주세요.");
    }

    @Test
    @DisplayName("닉네임 특수문자 포함 - 검증 실패")
    void invalidNickname_SpecialCharacters() {
        NicknameRequestDto dto = createDto("닉네임@#");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSize(1);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .contains("닉네임은 한글, 영문, 숫자만 사용 가능합니다.");
    }

    @Test
    @DisplayName("닉네임 공백 포함 - 검증 실패")
    void invalidNickname_WithSpace() {
        NicknameRequestDto dto = createDto("커플 맵");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSize(1);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .contains("닉네임은 한글, 영문, 숫자만 사용 가능합니다.");
    }

    @Test
    @DisplayName("닉네임 이모지 포함 - 검증 실패")
    void invalidNickname_WithEmoji() {
        NicknameRequestDto dto = createDto("커플맵😀");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSize(1);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .contains("닉네임은 한글, 영문, 숫자만 사용 가능합니다.");
    }

    @Test
    @DisplayName("여러 검증 규칙 동시 위반 - 1글자 + 특수문자")
    void invalidNickname_MultipleViolations() {
        NicknameRequestDto dto = createDto("@");

        Set<ConstraintViolation<NicknameRequestDto>> violations = validator.validate(dto);

        assertThat(violations).hasSizeGreaterThanOrEqualTo(2);
        assertThat(violations)
                .extracting(ConstraintViolation::getMessage)
                .containsAnyOf(
                        "닉네임은 2자 이상 10자 이하로 입력해주세요.",
                        "닉네임은 한글, 영문, 숫자만 사용 가능합니다."
                );
    }

    // 헬퍼 메서드
    private NicknameRequestDto createDto(String nickname) {
        try {
            NicknameRequestDto dto = new NicknameRequestDto();
            var field = NicknameRequestDto.class.getDeclaredField("nickname");
            field.setAccessible(true);
            field.set(dto, nickname);
            return dto;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}

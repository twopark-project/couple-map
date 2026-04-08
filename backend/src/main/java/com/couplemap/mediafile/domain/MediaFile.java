package com.couplemap.mediafile.domain;

import com.couplemap.global.common.BaseEntity;
import com.couplemap.global.s3.S3UploadDto;
import com.couplemap.memory.domain.Memory;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "media_files")
public class MediaFile extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "media_file_id")
    private Long mediaFileId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "memory_id", nullable = false)
    private Memory memory;

    // 파일 접근용
    @Column(name = "file_url", nullable = false, length = 500)
    private String fileUrl;

    // 파일 삭제용
    @Column(name = "file_key", nullable = false, length = 300)
    private String fileKey;

    @Column(name = "original_filename", length = 255)
    private String originalFilename;

    @Enumerated(EnumType.STRING)
    @Column(name = "media_file_type", nullable = false)
    private MediaFileType mediaFileType;  // IMAGE, VIDEO , AUDIO

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "display_order")
    private Integer displayOrder;

    @Builder
    private MediaFile(Memory memory, String fileUrl, String fileKey, String originalFilename, MediaFileType mediaFileType, Long fileSize, Integer displayOrder) {
        this.memory = memory;
        this.fileUrl = fileUrl;
        this.fileKey = fileKey;
        this.originalFilename = originalFilename;
        this.mediaFileType = mediaFileType;
        this.fileSize = fileSize;
        this.displayOrder = displayOrder;
    }

    public static MediaFile from(Memory memory, S3UploadDto s3Dto, MultipartFile file, MediaFileType type, int order) {
        return MediaFile.builder()
                .memory(memory)
                .fileUrl(s3Dto.getUrl())
                .fileKey(s3Dto.getKey())
                .originalFilename(file.getOriginalFilename())
                .mediaFileType(type)
                .fileSize(file.getSize())
                .displayOrder(order)
                .build();
    }
}

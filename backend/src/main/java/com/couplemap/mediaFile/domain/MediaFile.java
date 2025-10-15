package com.couplemap.mediaFile.domain;

import com.couplemap.global.common.BaseEntity;
import com.couplemap.memory.domain.Memory;
import jakarta.persistence.*;
import lombok.Getter;


@Entity
@Getter
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

    // 파일 다운로드용
    @Column(name = "original_filename", length = 255)
    private String originalFilename;

    @Enumerated(EnumType.STRING)
    @Column(name = "file_type", nullable = false)
    private MediaFileType mediaFileType;  // IMAGE, VIDEO , AUDIO

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "display_order")
    private Integer displayOrder;
}

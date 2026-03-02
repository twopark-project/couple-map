package com.couplemap.memory.dto;

import com.couplemap.mediaFile.domain.MediaFile;
import com.couplemap.mediaFile.domain.MediaFileType;
import lombok.Getter;

@Getter
public class MediaFileDto {
    private final Long mediaFileId;
    private final String fileUrl;
    private final String originalFilename;
    private final MediaFileType mediaFileType;
    private final Long fileSize;
    private final Integer displayOrder;

    public MediaFileDto(MediaFile mediaFile) {
        this.mediaFileId = mediaFile.getMediaFileId();
        this.fileUrl = mediaFile.getFileUrl();
        this.originalFilename = mediaFile.getOriginalFilename();
        this.mediaFileType = mediaFile.getMediaFileType();
        this.fileSize = mediaFile.getFileSize();
        this.displayOrder = mediaFile.getDisplayOrder();
    }
}

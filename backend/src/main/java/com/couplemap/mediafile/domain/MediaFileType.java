package com.couplemap.mediafile.domain;
import lombok.Getter;

@Getter
public enum MediaFileType {
    IMAGE("이미지"),
    VIDEO("동영상"),
    AUDIO("오디오");

    private final String description;

    MediaFileType(String description) {
        this.description = description;
    }
}

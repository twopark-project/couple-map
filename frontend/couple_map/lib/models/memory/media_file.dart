enum MediaFileType {
  IMAGE,
  VIDEO,
  AUDIO,
}

class MediaFile {
  final int mediaFileId;
  final String fileUrl;
  final String originalFilename;
  final MediaFileType mediaFileType;
  final int fileSize;
  final int displayOrder;

  MediaFile({
    required this.mediaFileId,
    required this.fileUrl,
    required this.originalFilename,
    required this.mediaFileType,
    required this.fileSize,
    required this.displayOrder,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      mediaFileId: json['mediaFileId'] as int,
      fileUrl: json['fileUrl'] as String,
      originalFilename: json['originalFilename'] as String,
      mediaFileType: MediaFileType.values.firstWhere(
        (e) => e.name == json['mediaFileType'],
        orElse: () => MediaFileType.IMAGE,
      ),
      fileSize: json['fileSize'] as int,
      displayOrder: json['displayOrder'] as int,
    );
  }
}

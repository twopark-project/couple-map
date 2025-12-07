import 'package:flutter/material.dart';
import '../../models/memory/memory_detail.dart';
import '../../models/memory/media_file.dart';

class MemoryDetailScreen extends StatelessWidget {
  final MemoryDetail memory;

  const MemoryDetailScreen({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final images = memory.mediaFiles.where((f) => f.mediaFileType == MediaFileType.IMAGE).toList();
    final videos = memory.mediaFiles.where((f) => f.mediaFileType == MediaFileType.VIDEO).toList();
    final audios = memory.mediaFiles.where((f) => f.mediaFileType == MediaFileType.AUDIO).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF191919)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '추억 상세',
          style: TextStyle(
            color: Color(0xFF191919),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 슬라이더
            if (images.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      images[index].fileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[100],
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                ),
              ),

            // 내용
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    memory.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191919),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 장소
                  Row(
                    children: [
                      const Icon(Icons.place, size: 20, color: Color(0xFF3182F6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          memory.placeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3182F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 날짜
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${memory.memoryDate.year}년 ${memory.memoryDate.month}월 ${memory.memoryDate.day}일',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  if (memory.content != null && memory.content!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      memory.content!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                  ],

                  // 비디오
                  if (videos.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.videocam, size: 20, color: Color(0xFF3182F6)),
                        const SizedBox(width: 8),
                        Text(
                          '비디오 (${videos.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191919),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...videos.map((video) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle_outline, color: Color(0xFF3182F6), size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  video.originalFilename,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  // 오디오
                  if (audios.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.audiotrack, size: 20, color: Color(0xFF3182F6)),
                        const SizedBox(width: 8),
                        Text(
                          '오디오 (${audios.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191919),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...audios.map((audio) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.music_note, color: Color(0xFF3182F6), size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  audio.originalFilename,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

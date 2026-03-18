import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/memory_model.dart';
import '../../domain/providers/memory_provider.dart';

class MemoryDetailScreen extends ConsumerStatefulWidget {
  final int mapId;
  final int memoryId;

  const MemoryDetailScreen({
    super.key,
    required this.mapId,
    required this.memoryId,
  });

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  MemoryModel? _memory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMemory();
  }

  Future<void> _loadMemory() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthSuccess) return;
    final accessToken = authState.token.accessToken;
    try {
      final memory = await ref.read(memoryRepositoryProvider).getMemoryDetail(
          accessToken, widget.mapId, widget.memoryId);
      if (mounted) {
        setState(() {
          _memory = memory;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF191919)),
          onPressed: () => context.pop(),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('오류: $_error'))
              : _memory == null
                  ? const Center(child: Text('데이터를 불러올 수 없습니다'))
                  : _buildBody(_memory!),
    );
  }

  Widget _buildBody(MemoryModel memory) {
    final images =
        memory.mediaFiles.where((f) => f.fileType == MediaType.image).toList();
    final videos =
        memory.mediaFiles.where((f) => f.fileType == MediaType.video).toList();
    final audios =
        memory.mediaFiles.where((f) => f.fileType == MediaType.audio).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 슬라이더
          if (images.isNotEmpty)
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) => Image.network(
                  images[index].fileUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 64, color: Colors.grey)),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[100],
              child: Center(
                child: Icon(Icons.image_outlined,
                    size: 80, color: Colors.grey[400]),
              ),
            ),

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
                    const Icon(Icons.place,
                        size: 20, color: Color(0xFF3182F6)),
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
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey),
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

                // 내용
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
                  _mediaSectionHeader(Icons.videocam, '비디오', videos.length),
                  const SizedBox(height: 12),
                  ...videos.map((v) =>
                      _mediaItem(Icons.play_circle_outline, v.originalFilename)),
                ],

                // 오디오
                if (audios.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _mediaSectionHeader(Icons.audiotrack, '오디오', audios.length),
                  const SizedBox(height: 12),
                  ...audios.map(
                      (a) => _mediaItem(Icons.music_note, a.originalFilename)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaSectionHeader(IconData icon, String label, int count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF3182F6)),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191919),
          ),
        ),
      ],
    );
  }

  Widget _mediaItem(IconData icon, String filename) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3182F6), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              filename,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

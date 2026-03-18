import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/memory_model.dart';
import '../../data/repositories/memory_repository.dart';
import 'memory_edit_screen.dart';
import 'photo_gallery_screen.dart';

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
  final MemoryRepository _repo = MemoryRepository();
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
    try {
      final memory = await _repo.getMemoryDetail(
          authState.token.accessToken, widget.mapId, widget.memoryId);
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

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '추억 삭제',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text('이 추억을 삭제할까요?\n삭제한 추억은 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제',
                style: TextStyle(
                    color: Color(0xFFE05555),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final auth = ref.read(authProvider);
      if (auth is! AuthSuccess) return;
      await _repo.deleteMemory(
          auth.token.accessToken, widget.mapId, widget.memoryId);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('삭제 실패'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8E8E)))
          : _error != null
              ? Center(
                  child: Text('오류: $_error',
                      style: const TextStyle(color: Colors.white)))
              : _memory == null
                  ? const Center(
                      child: Text('데이터를 불러올 수 없습니다',
                          style: TextStyle(color: Colors.white)))
                  : _buildBody(_memory!),
    );
  }

  Widget _buildBody(MemoryModel memory) {
    final images =
        memory.mediaFiles.where((f) => f.fileType == MediaType.image).toList();
    final audios =
        memory.mediaFiles.where((f) => f.fileType == MediaType.audio).toList();

    return Stack(
      children: [
        // 배경: 그라디언트 or 이미지
        Positioned.fill(
          child: images.isNotEmpty
              ? Image.network(
                  images.first.fileUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildGradientBg(),
                )
              : _buildGradientBg(),
        ),

        // 딤 오버레이
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),

        // 하단 콘텐츠 시트
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 40,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 핸들바
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 날짜 + 버튼 행
                        Row(
                          children: [
                            Text(
                              _formatDate(memory.memoryDate),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                            const Spacer(),
                            // 수정 버튼
                            _actionButton(
                              label: '수정',
                              bgColor: const Color(0xFFF5F3F0),
                              textColor: const Color(0xFF888888),
                              onTap: () async {
                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MemoryEditScreen(
                                      mapId: widget.mapId,
                                      memory: memory,
                                    ),
                                  ),
                                );
                                if (updated == true && mounted) {
                                  _loadMemory();
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            // 삭제 버튼
                            _actionButton(
                              label: '삭제',
                              bgColor: const Color(0xFFFFF0F0),
                              textColor: const Color(0xFFE05555),
                              onTap: () => _confirmDelete(),
                            ),
                            const SizedBox(width: 8),
                            // 닫기 버튼
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    '✕',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFAAAAAA),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 제목
                        Text(
                          memory.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2C2C),
                            fontFamily: 'NotoSerifKR',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // 장소
                        Row(
                          children: [
                            const Text(
                              '📍',
                              style: TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              memory.placeName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),

                        // 사진·동영상 섹션
                        if (images.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text(
                                '사진 · 동영상',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF888888),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F1F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${images.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFAAAAAA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PhotoGalleryScreen(
                                        mapId: widget.mapId,
                                        memoryId: widget.memoryId,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        child: Image.network(
                                          images[index].fileUrl,
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _imagePlaceholder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        // 오디오 섹션
                        if (audios.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text(
                                '오디오',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF888888),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F1F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${audios.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFAAAAAA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...audios.map((audio) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF8F5),
                                  border: Border.all(
                                      color: const Color(0xFFECE8E4)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // 재생 버튼
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFF8E8E),
                                            Color(0xFFFF7A7A),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // 파형 (시각적 표현)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildWaveform(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      audio.originalFilename
                                          .split('.')
                                          .first
                                          .length > 12
                                          ? '${audio.originalFilename.split('.').first.substring(0, 12)}...'
                                          : audio.originalFilename
                                              .split('.')
                                              .first,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFAAAAAA),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],

                        // 내용 텍스트
                        if (memory.content != null &&
                            memory.content!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F6F3),
                              border:
                                  Border.all(color: const Color(0xFFF0ECE8)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              memory.content!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                                height: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F0EC), Color(0xFFECE5DF)],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 32),
    );
  }

  Widget _buildWaveform() {
    final heights = [9.0, 16.0, 12.0, 21.0, 14.0, 9.0, 19.0, 13.0, 16.0, 10.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights
          .map((h) => Container(
                margin: const EdgeInsets.only(right: 2),
                width: 3,
                height: h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8E8E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ))
          .toList(),
    );
  }
}

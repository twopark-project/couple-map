import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/memory_model.dart';
import '../../data/repositories/memory_repository.dart';

class PhotoGalleryScreen extends ConsumerStatefulWidget {
  final int mapId;
  final int memoryId;

  const PhotoGalleryScreen({
    super.key,
    required this.mapId,
    required this.memoryId,
  });

  @override
  ConsumerState<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends ConsumerState<PhotoGalleryScreen> {
  final MemoryRepository _repo = MemoryRepository();
  List<MediaFile> _images = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    try {
      final memory = await _repo.getMemoryDetail(
        auth.token.accessToken,
        widget.mapId,
        widget.memoryId,
      );
      if (mounted) {
        setState(() {
          _images = memory.mediaFiles
              .where((f) => f.fileType == MediaType.image)
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: _images.isEmpty
            ? null
            : Text(
                '${_currentIndex + 1} / ${_images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _images.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_not_supported_outlined,
                          size: 64, color: Colors.white38),
                      SizedBox(height: 16),
                      Text(
                        '사진이 없어요',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : PageView.builder(
                  itemCount: _images.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      child: Center(
                        child: Image.network(
                          _images[index].fileUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white38,
                            size: 64,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

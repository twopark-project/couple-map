import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../domain/providers/memory_provider.dart';

class MemoryCreateScreen extends ConsumerStatefulWidget {
  final int mapId;
  final String? placeName;
  final double? latitude;
  final double? longitude;

  const MemoryCreateScreen({
    super.key,
    required this.mapId,
    this.placeName,
    this.latitude,
    this.longitude,
  });

  @override
  ConsumerState<MemoryCreateScreen> createState() => _MemoryCreateScreenState();
}

class _MemoryCreateScreenState extends ConsumerState<MemoryCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (!mounted) return;
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages = picked.map((x) => File(x.path)).toList();
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;

    setState(() => _isSaving = true);
    try {
      final requestData = {
        'title': title,
        'content': _contentController.text.trim(),
        if (widget.placeName != null) 'placeName': widget.placeName,
        if (widget.latitude != null) 'latitude': widget.latitude,
        if (widget.longitude != null) 'longitude': widget.longitude,
        'memoryDate': DateTime.now().toIso8601String().split('T').first,
      };
      await ref.read(memoryRepositoryProvider).createMemory(
        auth.token.accessToken,
        widget.mapId,
        requestData,
        _selectedImages.isNotEmpty ? _selectedImages : null,
      );
      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          icon: const Icon(Icons.close, color: Color(0xFF191919)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '추억 남기기',
          style: TextStyle(
              color: Color(0xFF191919),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFFF7A7A)),
                  )
                : const Text('저장',
                    style: TextStyle(
                        color: Color(0xFFFF7A7A),
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 장소
            if (widget.placeName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 18, color: Color(0xFF3182F6)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.placeName!,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3182F6)),
                      ),
                    ),
                  ],
                ),
              ),

            // 제목
            TextField(
              controller: _titleController,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919)),
              decoration: InputDecoration(
                hintText: '제목을 입력하세요',
                hintStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),

            // 내용
            TextField(
              controller: _contentController,
              maxLines: 8,
              style: const TextStyle(fontSize: 16, height: 1.6),
              decoration: InputDecoration(
                hintText: '이 순간의 기억을 남겨보세요...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),

            // 사진 추가
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 32, color: Color(0xFFFF7A7A)),
                    SizedBox(height: 8),
                    Text('사진 추가',
                        style: TextStyle(
                            color: Color(0xFFFF7A7A),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            // 선택된 이미지 미리보기
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _selectedImages.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

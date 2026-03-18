import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../home/domain/providers/home_provider.dart';

class MapCreateScreen extends ConsumerStatefulWidget {
  const MapCreateScreen({super.key});

  @override
  ConsumerState<MapCreateScreen> createState() => _MapCreateScreenState();
}

class _MapCreateScreenState extends ConsumerState<MapCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _coverImage;
  int _selectedGradient = 0;
  String _selectedCategory = '나 혼자';
  DateTime _startDate = DateTime.now();
  bool _isCreating = false;

  static const List<String> _categories = ['나 혼자', '친구들과', '연인과', '가족'];

  static const List<List<Color>> _gradients = [
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    var status = await Permission.photos.status;
    if (!status.isGranted && !status.isLimited) {
      status = await Permission.photos.request();
    }
    if (!status.isGranted && !status.isLimited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 접근 권한이 필요합니다')),
        );
      }
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _coverImage = File(picked.path));
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    setState(() => _isCreating = true);
    try {
      final mapId = await ref.read(homeRepositoryProvider).createMap(
        auth.token.accessToken,
        name,
        _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        _coverImage,
      );
      if (mounted) context.pop(mapId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F5),
        elevation: 0,
        surfaceTintColor: const Color(0xFFFAF8F5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF191919), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '지도 만들기',
          style: TextStyle(
            color: Color(0xFF191919),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 커버 사진
                  SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 배경: 사진 or 그라디언트
                        _coverImage != null
                            ? Image.file(_coverImage!, fit: BoxFit.cover)
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _gradients[_selectedGradient],
                                  ),
                                ),
                              ),
                        Container(color: Colors.black.withValues(alpha: 0.2)),
                        // 커버 사진 변경 (정중앙)
                        GestureDetector(
                          onTap: _pickCoverImage,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, color: Colors.white, size: 26),
                                SizedBox(height: 6),
                                Text(
                                  '커버 사진 변경',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 그라디언트 선택 (이미지 없을 때만, 우하단)
                        if (_coverImage == null)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Row(
                              children: List.generate(_gradients.length, (i) {
                                final isSelected = _selectedGradient == i;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedGradient = i),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(left: 6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: _gradients[i],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: isSelected
                                          ? Border.all(color: Colors.white, width: 2.5)
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        // 사진 선택 취소 버튼 (이미지 있을 때)
                        if (_coverImage != null)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => setState(() => _coverImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 지도 이름
                        const Text(
                          '지도 이름',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF191919)),
                          decoration: InputDecoration(
                            hintText: '우정 여행 아카이브',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFFAF8F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFECE8E4)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFECE8E4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFF7A7A)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 설명
                        const Text(
                          '설명',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descController,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF191919)),
                          decoration: InputDecoration(
                            hintText: '짧은 설명 (예: 맛집 도장깨기)',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFFAF8F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFECE8E4)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFECE8E4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFF7A7A)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 카테고리
                        const Text(
                          '카테고리',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFF0F0)
                                        : const Color(0xFFF1F3F5),
                                    borderRadius: BorderRadius.circular(20),
                                    border: isSelected
                                        ? Border.all(color: const Color(0xFFFFB5B5))
                                        : null,
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFFFB5B5)
                                          : const Color(0xFF868E96),
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // 시작일
                        const Text(
                          '시작일',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickStartDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF8F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFECE8E4)),
                            ),
                            child: Text(
                              '${_startDate.year}. '
                              '${_startDate.month.toString().padLeft(2, '0')}. '
                              '${_startDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF191919),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 완료 버튼
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isCreating || _nameController.text.trim().isEmpty ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A7A),
                  disabledBackgroundColor: const Color(0xFFFFB5B5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '완료',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

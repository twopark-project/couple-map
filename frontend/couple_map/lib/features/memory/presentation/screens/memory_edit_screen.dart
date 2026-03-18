import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/memory_model.dart';
import '../../data/repositories/memory_repository.dart';

class MemoryEditScreen extends ConsumerStatefulWidget {
  final int mapId;
  final MemoryModel memory;

  const MemoryEditScreen({
    super.key,
    required this.mapId,
    required this.memory,
  });

  @override
  ConsumerState<MemoryEditScreen> createState() => _MemoryEditScreenState();
}

class _MemoryEditScreenState extends ConsumerState<MemoryEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final MemoryRepository _repo = MemoryRepository();
  final ImagePicker _picker = ImagePicker();

  late DateTime _selectedDate;
  final List<File> _newImages = [];
  final List<File> _newAudios = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memory.title);
    _contentController =
        TextEditingController(text: widget.memory.content ?? '');
    _selectedDate = widget.memory.memoryDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _newImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _newAudios.addAll(result.files.map((f) => File(f.path!)));
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF8E8E),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('제목을 입력해주세요'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;

    setState(() => _isSaving = true);
    try {
      final requestData = {
        'title': title,
        'content':
            _contentController.text.trim().isNotEmpty
                ? _contentController.text.trim()
                : null,
        'placeName': widget.memory.placeName,
        'latitude': widget.memory.latitude,
        'longitude': widget.memory.longitude,
        'memoryDate': _selectedDate.toIso8601String().split('T').first,
      };
      final allNewFiles = [..._newImages, ..._newAudios];
      await _repo.updateMemory(
        auth.token.accessToken,
        widget.mapId,
        widget.memory.memoryId,
        requestData,
        allNewFiles.isNotEmpty ? allNewFiles : null,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('수정 실패'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}. ${date.month.toString().padLeft(2, '0')}. ${date.day.toString().padLeft(2, '0')}';
  }

  List<MediaFile> get _existingImages =>
      widget.memory.mediaFiles
          .where((f) => f.fileType == MediaType.image)
          .toList();

  List<MediaFile> get _existingAudios =>
      widget.memory.mediaFiles
          .where((f) => f.fileType == MediaType.audio)
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDFBF7),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0ECE8), width: 1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      '◀',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '추억 수정',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // 본문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 장소 카드 (수정 불가)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text('📍',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.memory.placeName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 제목
                    const Text('제목',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2C2C))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black),
                      decoration: _inputDecoration('추억의 제목을 적어주세요'),
                    ),
                    const SizedBox(height: 20),

                    // 내용
                    const Text('내용',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2C2C))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      maxLines: 4,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black),
                      decoration: _inputDecoration('어떤 하루였나요?'),
                    ),
                    const SizedBox(height: 20),

                    // 날짜
                    const Text('날짜',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2C2C))),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: const Color(0xFFEEEEEE)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 기존 사진
                    if (_existingImages.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text('기존 사진',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2C2C2C))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_existingImages.length}',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFFAAAAAA)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _existingImages[index].fileUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: Icon(Icons.image_outlined,
                                    color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 사진 추가
                    const Text('사진 추가',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2C2C))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: const Color(0xFFDDDDDD)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('+',
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color(0xFFAAAAAA),
                                      fontWeight: FontWeight.w300)),
                            ),
                          ),
                        ),
                        if (_newImages.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _newImages.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) => Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      child: Image.file(
                                        _newImages[index],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () => setState(() =>
                                            _newImages.removeAt(index)),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close,
                                              size: 12,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 기존 오디오
                    if (_existingAudios.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text('기존 오디오',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2C2C2C))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_existingAudios.length}',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFFAAAAAA)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._existingAudios.map((audio) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.music_note,
                                    color: Color(0xFFFF8E8E), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    audio.originalFilename,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF2C2C2C)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 12),
                    ],

                    // 오디오 추가
                    const Text('오디오 추가',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2C2C))),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickAudio,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: const Color(0xFFDDDDDD)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFDDDDDD)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('+',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFFAAAAAA))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('오디오 추가',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF888888))),
                          ],
                        ),
                      ),
                    ),
                    if (_newAudios.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ..._newAudios.asMap().entries.map((entry) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.music_note,
                                    color: Color(0xFFFF8E8E), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.value.path.split('/').last,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF2C2C2C)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _newAudios.removeAt(entry.key)),
                                  child: const Icon(Icons.close,
                                      size: 16,
                                      color: Color(0xFFAAAAAA)),
                                ),
                              ],
                            ),
                          )),
                    ],
                    const SizedBox(height: 32),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('저장하기',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 취소 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF888888),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('취소',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFFBBBBBB), fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF8E8E)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

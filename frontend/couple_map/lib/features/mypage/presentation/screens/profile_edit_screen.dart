import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/providers/mypage_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _nicknameController;
  bool _isSaving = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.user.nickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2 || nickname.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임은 2-10자로 입력해주세요')),
      );
      return;
    }
    final regex = RegExp(r'^[가-힣a-zA-Z0-9]+$');
    if (!regex.hasMatch(nickname)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('한글, 영문, 숫자만 사용 가능합니다')),
      );
      return;
    }
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(mypageRepositoryProvider).updateNickname(auth.token.accessToken, nickname);
      if (_pickedImage != null) {
        await ref.read(mypageRepositoryProvider).uploadProfileImage(auth.token.accessToken, _pickedImage!);
      }
      if (mounted) {
        setState(() => _pickedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '프로필이 수정되었어요!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFFF8E8E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정에 실패했어요. 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF191919), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            color: Color(0xFF191919),
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF7A7A),
                    ),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      color: Color(0xFFFF7A7A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            // 프로필 아바타
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE4E4),
                        shape: BoxShape.circle,
                      ),
                      child: _pickedImage != null
                          ? ClipOval(
                              child: Image.file(_pickedImage!, fit: BoxFit.cover),
                            )
                          : widget.user.profileImageUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    widget.user.profileImageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Text('🐻', style: TextStyle(fontSize: 44)),
                                ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 닉네임
            const Text(
              '닉네임',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF7A7A)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF2C2C2C)),
            ),
            const SizedBox(height: 6),
            const Text(
              '2~10지의 한글, 영문, 숫자를 사용해요.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 28),
            // 친구 코드
            const Text(
              '내 친구 코드',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.user.friendCode,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF2C2C2C)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.user.friendCode));
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    backgroundColor: const Color(0xFFF2F2F2),
                  ),
                  child: const Text(
                    '복사',
                    style: TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

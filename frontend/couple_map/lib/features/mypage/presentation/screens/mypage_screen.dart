import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/repositories/mypage_repository.dart';
import 'profile_edit_screen.dart';

class MypageScreen extends ConsumerStatefulWidget {
  const MypageScreen({super.key});

  @override
  ConsumerState<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends ConsumerState<MypageScreen> {
  final MypageRepository _repo = MypageRepository();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    try {
      final user = await _repo.getUserInfo(auth.token.accessToken);
      if (mounted) setState(() { _user = user; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('친구 코드가 복사되었어요!')));
  }

  void _logout() {
    ref.read(authProvider.notifier).reset();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
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
        title: const Text(
          '마이페이지',
          style: TextStyle(
              color: Color(0xFF191919),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF191919)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ).then((_) => _loadUser()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('정보를 불러올 수 없습니다'))
              : _buildBody(_user!),
    );
  }

  Widget _buildBody(UserModel user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          // 프로필
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFFFE5E5),
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Text(
                          user.nickname[0],
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF7A7A)),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.nickname,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191919)),
                ),
                const SizedBox(height: 4),
                Text(user.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 친구 코드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, color: Color(0xFFFF7A7A)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('내 친구 코드',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFFF7A7A))),
                        Text(
                          user.friendCode,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFFFF7A7A)),
                    onPressed: () => _copyCode(user.friendCode),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(height: 1),

          // 메뉴
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

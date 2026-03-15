import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../mypage/data/repositories/mypage_repository.dart';
import '../../data/repositories/friend_repository.dart';
import 'friend_invite_screen.dart';

class FriendScreen extends ConsumerStatefulWidget {
  const FriendScreen({super.key});

  @override
  ConsumerState<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends ConsumerState<FriendScreen> {
  final FriendRepository _friendRepo = FriendRepository();
  final MypageRepository _mypageRepo = MypageRepository();

  List<FriendInfo> _friends = [];
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    final token = auth.token.accessToken;
    try {
      final results = await Future.wait([
        _friendRepo.getFriendList(token),
        _mypageRepo.getUserInfo(token),
      ]);
      if (mounted) {
        setState(() {
          _friends = results[0] as List<FriendInfo>;
          _user = results[1] as UserModel;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInviteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FriendInviteSheet(onAdded: _loadData),
    );
  }

  void _copyCode() {
    if (_user == null) return;
    Clipboard.setData(ClipboardData(text: _user!.friendCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('친구 코드를 복사했어요!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        surfaceTintColor: const Color(0xFFFDFBF7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF191919), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '친구 관리',
          style: TextStyle(
            color: Color(0xFF191919),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _showInviteSheet,
            child: const Text(
              '+ 추가',
              style: TextStyle(
                color: Color(0xFFFF7A7A),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMyCodeCard(),
          const SizedBox(height: 24),
          const Text(
            '내 친구 목록',
            style: TextStyle(
              color: Color(0xFF191919),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _friends.isEmpty ? _buildEmptyState() : _buildFriendList(),
        ],
      ),
    );
  }

  Widget _buildMyCodeCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 친구 코드',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _user?.friendCode ?? '...',
                  style: const TextStyle(
                    color: Color(0xFF191919),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _copyCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191919),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '코드 복사',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '아직 친구가 없어요',
              style: TextStyle(
                color: Color(0xFF191919),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '친구 코드를 입력하거나\n내 코드를 공유해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendList() {
    return Column(
      children: _friends.map((f) => _FriendTile(friend: f)).toList(),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final FriendInfo friend;

  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    final codeLabel = friend.friendCode != null ? '#${friend.friendCode}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF2F0EC),
            ),
            child: friend.imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      friend.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('🐶', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  )
                : const Center(
                    child: Text('🐶', style: TextStyle(fontSize: 22)),
                  ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.nickname,
                style: const TextStyle(
                  color: Color(0xFF191919),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                codeLabel,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

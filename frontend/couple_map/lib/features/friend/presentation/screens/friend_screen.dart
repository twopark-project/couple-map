import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/repositories/friend_repository.dart';
import 'friend_invite_screen.dart';

class FriendScreen extends ConsumerStatefulWidget {
  const FriendScreen({super.key});

  @override
  ConsumerState<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends ConsumerState<FriendScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendRepository _repo = FriendRepository();

  List<FriendInfo> _friends = [];
  List<FriendPendingInfo> _pending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    final token = auth.token.accessToken;
    try {
      final results = await Future.wait([
        _repo.getFriendList(token),
        _repo.getPendingFriendList(token),
      ]);
      if (mounted) {
        setState(() {
          _friends = results[0] as List<FriendInfo>;
          _pending = results[1] as List<FriendPendingInfo>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(int friendshipId) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    await _repo.acceptFriendRequest(auth.token.accessToken, friendshipId);
    _loadData();
  }

  Future<void> _rejectRequest(int friendshipId) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    await _repo.rejectFriendRequest(auth.token.accessToken, friendshipId);
    _loadData();
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
          '친구 관리',
          style: TextStyle(
            color: Color(0xFF191919),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Color(0xFFFF7A7A)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FriendInviteScreen()),
            ).then((_) => _loadData()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF7A7A),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF7A7A),
          tabs: [
            Tab(text: '친구 (${_friends.length})'),
            Tab(text: '요청 (${_pending.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildFriendList(), _buildPendingList()],
            ),
    );
  }

  Widget _buildFriendList() {
    if (_friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('아직 친구가 없어요', style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: 8),
            Text('친구 코드로 친구를 추가해보세요',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final f = _friends[index];
        return _FriendTile(nickname: f.nickname, email: f.email, imageUrl: f.imageUrl);
      },
    );
  }

  Widget _buildPendingList() {
    if (_pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('받은 친구 요청이 없어요',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pending.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final req = _pending[index];
        return Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFFFE5E5),
                  backgroundImage: req.imageUrl != null
                      ? NetworkImage(req.imageUrl!)
                      : null,
                  child: req.imageUrl == null
                      ? Text(req.nickname[0],
                          style: const TextStyle(
                              color: Color(0xFFFF7A7A),
                              fontWeight: FontWeight.w700))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.nickname,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(req.email,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _acceptRequest(req.friendshipId),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF7A7A)),
                  child: const Text('수락'),
                ),
                TextButton(
                  onPressed: () => _rejectRequest(req.friendshipId),
                  style:
                      TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('거절'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FriendTile extends StatelessWidget {
  final String nickname;
  final String email;
  final String? imageUrl;

  const _FriendTile(
      {required this.nickname, required this.email, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFE5E5),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(nickname[0],
                  style: const TextStyle(
                      color: Color(0xFFFF7A7A), fontWeight: FontWeight.w700))
              : null,
        ),
        title: Text(nickname,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(email, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

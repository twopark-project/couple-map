import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/repositories/friend_repository.dart';

class FriendInviteScreen extends ConsumerStatefulWidget {
  const FriendInviteScreen({super.key});

  @override
  ConsumerState<FriendInviteScreen> createState() => _FriendInviteScreenState();
}

class _FriendInviteScreenState extends ConsumerState<FriendInviteScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FriendRepository _repo = FriendRepository();
  bool _isSending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    setState(() => _isSending = true);
    try {
      await _repo.sendFriendRequest(auth.token.accessToken, code);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('친구 요청을 보냈어요!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '친구 추가',
          style: TextStyle(
              color: Color(0xFF191919),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '친구 코드로 추가',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191919),
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text('친구의 코드를 입력해 친구 요청을 보내세요.',
                style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: '친구 코드 입력',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A7A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('친구 요청 보내기',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

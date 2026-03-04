import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_token.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());

sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final AuthToken token;
  AuthSuccess(this.token);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthInitial();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> loginWithKakao() => _login(_repo.loginWithKakao);
  Future<void> loginWithGoogle() => _login(_repo.loginWithGoogle);
  Future<void> loginWithNaver() => _login(_repo.loginWithNaver);

  Future<void> _login(Future<AuthToken> Function() loginFn) async {
    state = AuthLoading();
    try {
      final token = await loginFn();
      await _repo.saveToken(token);
      state = AuthSuccess(token);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> setNickname(String accessToken, String nickname) async {
    state = AuthLoading();
    try {
      await _repo.setNickname(accessToken, nickname);
      final current = state;
      if (current is AuthSuccess) {
        state = AuthSuccess(AuthToken(
          accessToken: current.token.accessToken,
          refreshToken: current.token.refreshToken,
          expiresIn: current.token.expiresIn,
          nicknameSet: true,
        ));
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  void reset() => state = AuthInitial();
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

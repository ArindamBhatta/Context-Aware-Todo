import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthUnauthenticated());

  Future<void> syncAuthState() async {
    final AuthUser? user = _repository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<bool> signInWithGoogle() async {
    final bool isLoggedIn = await _repository.signInWithGoogle();
    if (isLoggedIn) {
      final AuthUser? user = _repository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    }
    return isLoggedIn;
  }

  Future<void> logout() async {
    await _repository.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<bool> isLoggedIn() => _repository.isLoggedIn();

  Future<bool> isBiometricEnabled() => _repository.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) =>
      _repository.setBiometricEnabled(enabled);

  Future<bool> hasAppLockCredential() => _repository.hasAppLockCredential();

  Future<void> saveAppLockCredential(String secret) =>
      _repository.saveAppLockCredential(secret);

  Future<bool> verifyAppLockCredential(String secret) =>
      _repository.verifyAppLockCredential(secret);
}

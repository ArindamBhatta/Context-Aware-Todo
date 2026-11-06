import '../service/local_auth_service.dart';
import '../model/user_model.dart';

class AuthRepository {
  final LocalAuthService _localAuthService;

  AuthRepository(LocalAuthService localAuthService)
    : _localAuthService = localAuthService;

  Future<bool> isLoggedIn() => _localAuthService.isSignedIn();

  Future<UserModel?> getCurrentUser() async {
    if (!await _localAuthService.isSignedIn()) {
      return null;
    }
    return const UserModel(displayName: 'User');
  }

  /// Local sign-in. The Laravel backend has no authentication yet, so this
  /// only marks the device as signed in (the app lock still protects access).
  Future<bool> signIn() async {
    await _localAuthService.setSignedIn(true);
    return true;
  }

  Future<bool> isBiometricEnabled() => _localAuthService.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) =>
      _localAuthService.setBiometricEnabled(enabled);

  Future<bool> hasAppLockCredential() =>
      _localAuthService.hasAppLockCredential();

  Future<void> saveAppLockCredential(String secret) =>
      _localAuthService.saveAppLockCredential(secret);

  Future<bool> verifyAppLockCredential(String secret) =>
      _localAuthService.verifyAppLockCredential(secret);

  Future<void> signOut() async {
    await _localAuthService.setSignedIn(false);
    await _localAuthService.clearAppLockCredential();
    await _localAuthService.setBiometricEnabled(false);
  }
}

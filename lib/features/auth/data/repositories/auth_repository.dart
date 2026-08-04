import '../service/local_auth_service.dart';
import '../service/google_auth_service.dart';
import '../model/user_model.dart';

class AuthRepository {
  final LocalAuthService _localAuthService;
  final GoogleAuthService _googleAuthService;

  AuthRepository(
    LocalAuthService localAuthService, {
    GoogleAuthService? googleAuthService,
  }) : _localAuthService = localAuthService,
       _googleAuthService = googleAuthService ?? GoogleAuthService();

  Future<bool> isLoggedIn() async => _googleAuthService.isLoggedIn();

  UserModel? getCurrentUser() => _googleAuthService.getCurrentUser();

  Future<bool> signInWithGoogle() => _googleAuthService.signInWithGoogle();

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
    await _googleAuthService.signOut();
    await _localAuthService.clearAppLockCredential();
    await _localAuthService.setBiometricEnabled(false);
  }
}

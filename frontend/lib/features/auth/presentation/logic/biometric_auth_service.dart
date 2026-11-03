import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth;

  BiometricAuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> canUseDeviceAuth() async {
    try {
      return _localAuth.isDeviceSupported();
    } on LocalAuthException {
      return false;
    }
  }

  Future<bool> authenticateWithDeviceCredentials() async {
    final bool available = await canUseDeviceAuth();
    if (!available) {
      return false;
    }

    try {
      return _localAuth.authenticate(
        localizedReason:
            'Authenticate with your device password, PIN, pattern, or biometrics to unlock.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const String _biometricEnabledKey = 'auth_biometric_enabled';

  static const String _appLockSecretHashKey = 'auth_app_lock_secret_hash';

  // FlutterSecureStorage
  static const FlutterSecureStorage _defaultSecureStorage =
      FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  final FlutterSecureStorage _secureStorage;

  LocalAuthService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? _defaultSecureStorage;

  Future<bool> isBiometricEnabled() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> hasAppLockCredential() async {
    final String? storedHash = await _secureStorage.read(
      key: _appLockSecretHashKey,
    );
    return storedHash != null && storedHash.isNotEmpty;
  }

  Future<void> saveAppLockCredential(String secret) async {
    await _secureStorage.write(
      key: _appLockSecretHashKey,
      value: _hashSecret(secret),
    );
  }

  Future<bool> verifyAppLockCredential(String secret) async {
    final String? storedHash = await _secureStorage.read(
      key: _appLockSecretHashKey,
    );

    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }

    return storedHash == _hashSecret(secret);
  }

  Future<void> clearAppLockCredential() async {
    await _secureStorage.delete(key: _appLockSecretHashKey);
  }

  String _hashSecret(String secret) {
    return sha256.convert(utf8.encode(secret)).toString();
  }
}

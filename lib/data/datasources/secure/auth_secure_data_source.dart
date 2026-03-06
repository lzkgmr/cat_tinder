import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthSecureDataSource {
  Future<void> savePassword(String normalizedEmail, String password);

  Future<String?> readPassword(String normalizedEmail);
}

class KeychainAuthSecureDataSource implements AuthSecureDataSource {
  static const _passwordKeyPrefix = 'auth_password_';
  final FlutterSecureStorage _secureStorage;

  KeychainAuthSecureDataSource(this._secureStorage);

  @override
  Future<void> savePassword(String normalizedEmail, String password) async {
    await _secureStorage.write(
      key: _passwordKey(normalizedEmail),
      value: password,
    );
  }

  @override
  Future<String?> readPassword(String normalizedEmail) async {
    return _secureStorage.read(key: _passwordKey(normalizedEmail));
  }

  String _passwordKey(String normalizedEmail) {
    return '$_passwordKeyPrefix$normalizedEmail';
  }
}

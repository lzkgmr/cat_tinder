import 'package:cat_tinder/data/datasources/local/auth_local_data_source.dart';
import 'package:cat_tinder/data/datasources/secure/auth_secure_data_source.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthSecureDataSource _secureDataSource;

  LocalAuthRepository({
    required AuthLocalDataSource localDataSource,
    required AuthSecureDataSource secureDataSource,
  }) : _localDataSource = localDataSource,
       _secureDataSource = secureDataSource;

  @override
  Future<void> register({required String email, required String password}) async {
    final normalizedEmail = _normalizeEmail(email);
    final users = await _registeredUsers();

    if (users.contains(normalizedEmail)) {
      throw StateError('Account already exists for this email');
    }

    users.add(normalizedEmail);
    await _localDataSource.saveRegisteredEmails(users);
    await _secureDataSource.savePassword(normalizedEmail, password);
  }

  @override
  Future<bool> validateCredentials({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (!await hasAccount(normalizedEmail)) {
      return false;
    }

    final storedPassword = await _secureDataSource.readPassword(normalizedEmail);
    return storedPassword == password;
  }

  @override
  Future<bool> hasAccount(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    return (await _registeredUsers()).contains(normalizedEmail);
  }

  Future<Set<String>> _registeredUsers() async {
    final users = await _localDataSource.getRegisteredEmails();
    return users.map(_normalizeEmail).toSet();
  }

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }
}

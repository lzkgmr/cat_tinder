import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<Set<String>> getRegisteredEmails();

  Future<void> saveRegisteredEmails(Set<String> emails);
}

class SharedPrefsAuthLocalDataSource implements AuthLocalDataSource {
  static const _registeredUsersKey = 'auth_registered_users';
  final SharedPreferences _prefs;

  SharedPrefsAuthLocalDataSource(this._prefs);

  @override
  Future<Set<String>> getRegisteredEmails() async {
    final users = _prefs.getStringList(_registeredUsersKey) ?? <String>[];
    return users.map((email) => email.trim().toLowerCase()).toSet();
  }

  @override
  Future<void> saveRegisteredEmails(Set<String> emails) async {
    await _prefs.setStringList(_registeredUsersKey, emails.toList());
  }
}

import 'package:shared_preferences/shared_preferences.dart';

abstract class SessionLocalDataSource {
  Future<void> saveCurrentUserEmail(String email);

  Future<String?> getCurrentUserEmail();

  Future<void> clearCurrentUserEmail();
}

class SharedPrefsSessionLocalDataSource implements SessionLocalDataSource {
  static const _currentUserKey = 'session_current_user_email';
  final SharedPreferences _prefs;

  SharedPrefsSessionLocalDataSource(this._prefs);

  @override
  Future<void> saveCurrentUserEmail(String email) async {
    await _prefs.setString(_currentUserKey, email);
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return _prefs.getString(_currentUserKey);
  }

  @override
  Future<void> clearCurrentUserEmail() async {
    await _prefs.remove(_currentUserKey);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _likesKey = 'likes_count';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  int getLikes() {
    return _prefs.getInt(_likesKey) ?? 0;
  }

  Future<void> setLikes(int value) async {
    await _prefs.setInt(_likesKey, value);
  }
}

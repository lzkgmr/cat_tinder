import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cat.dart';

class StorageService {
  static const String _likesKey = 'likes_count';
  static const String _likedCatsKey = 'liked_cats';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  int getLikes() {
    return _prefs.getInt(_likesKey) ?? 0;
  }

  Future<void> setLikes(int value) async {
    await _prefs.setInt(_likesKey, value);
  }

  List<Cat> getLikedCats() {
    final jsonList = _prefs.getStringList(_likedCatsKey) ?? [];
    return jsonList.map((str) => Cat.fromJson(json.decode(str))).toList();
  }

  Future<void> addLikedCat(Cat cat) async {
    final currentCats = getLikedCats();
    if (currentCats.any((c) => c.id == cat.id)) return;

    currentCats.add(cat);
    final jsonList = currentCats.map((c) => json.encode(c.toJson())).toList();
    await _prefs.setStringList(_likedCatsKey, jsonList);
  }

  Future<void> removeLikedCat(String catId) async {
    final currentCats = getLikedCats();
    final updatedCats = currentCats.where((c) => c.id != catId).toList();
    final jsonList = updatedCats.map((c) => json.encode(c.toJson())).toList();
    await _prefs.setStringList(_likedCatsKey, jsonList);
    
    final currentLikes = getLikes();
    await setLikes(currentLikes - 1);
  }

  Future<void> clearLikedCats() async {
    await _prefs.remove(_likedCatsKey);
    await _prefs.remove(_likesKey);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

abstract class ReelsLocalDataSource {
  Future<Set<String>> getLikedVideoIds();
  Future<Set<String>> getStarredVideoIds();
  Future<void> setLiked(String videoId, bool liked);
  Future<void> setStarred(String videoId, bool starred);
}

class ReelsLocalDataSourceImpl implements ReelsLocalDataSource {
  ReelsLocalDataSourceImpl({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _likedKey = 'liked_video_ids';
  static const _starredKey = 'starred_video_ids';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<Set<String>> getLikedVideoIds() async {
    final prefs = await _prefs;
    return prefs.getStringList(_likedKey)?.toSet() ?? {};
  }

  @override
  Future<Set<String>> getStarredVideoIds() async {
    final prefs = await _prefs;
    return prefs.getStringList(_starredKey)?.toSet() ?? {};
  }

  @override
  Future<void> setLiked(String videoId, bool liked) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList(_likedKey)?.toSet() ?? {};
    if (liked) {
      ids.add(videoId);
    } else {
      ids.remove(videoId);
    }
    await prefs.setStringList(_likedKey, ids.toList());
  }

  @override
  Future<void> setStarred(String videoId, bool starred) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList(_starredKey)?.toSet() ?? {};
    if (starred) {
      ids.add(videoId);
    } else {
      ids.remove(videoId);
    }
    await prefs.setStringList(_starredKey, ids.toList());
  }
}

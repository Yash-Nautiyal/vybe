import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vybe/features/reels/data/models/video_model.dart';

abstract class ReelsLocalDataSource {
  Future<Set<String>> getLikedVideoIds();
  Future<Set<String>> getStarredVideoIds();
  Future<List<VideoModel>> getCachedVideos();
  Future<void> cacheVideos(List<VideoModel> videos);
  Future<void> setLiked(String videoId, bool liked);
  Future<void> setStarred(String videoId, bool starred);
}

class ReelsLocalDataSourceImpl implements ReelsLocalDataSource {
  ReelsLocalDataSourceImpl({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _likedKey = 'liked_video_ids';
  static const _starredKey = 'starred_video_ids';
  static const _cachedVideosKey = 'cached_reel_feed';

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
  Future<List<VideoModel>> getCachedVideos() async {
    final prefs = await _prefs;
    final rawVideos = prefs.getStringList(_cachedVideosKey) ?? const [];

    return rawVideos
        .map((raw) => jsonDecode(raw))
        .whereType<Map<String, dynamic>>()
        .map(VideoModel.fromJson)
        .where((video) => video.id.isNotEmpty && video.videoUrl.isNotEmpty)
        .toList();
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _cachedVideosKey,
      videos.map((video) => jsonEncode(video.toJson())).toList(),
    );
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

import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileLocalDataSource {
  Future<List<String>> getOrAssignPostVideoIds(List<String> availableIds);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _postIdsKey = 'profile_post_video_ids';
  static const _postCount = 5;

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<List<String>> getOrAssignPostVideoIds(
    List<String> availableIds,
  ) async {
    if (availableIds.isEmpty) return [];

    final prefs = await _prefs;
    final stored = prefs.getStringList(_postIdsKey) ?? [];
    final validStored =
        stored.where((id) => availableIds.contains(id)).toList();

    if (validStored.length >= _postCount) {
      return validStored.take(_postCount).toList();
    }

    final shuffled = List<String>.from(availableIds)..shuffle(Random());
    final picked = <String>{...validStored};
    for (final id in shuffled) {
      if (picked.length >= _postCount) break;
      picked.add(id);
    }

    final result = picked.take(_postCount).toList();
    await prefs.setStringList(_postIdsKey, result);
    return result;
  }
}

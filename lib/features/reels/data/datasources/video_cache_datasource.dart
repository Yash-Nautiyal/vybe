import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vybe/core/error/exception.dart';
import 'package:vybe/features/reels/data/datasources/video_cache_manager.dart';

/// Local disk cache for remote MP4 files.
abstract class VideoCacheDataSource {
  Future<File> getVideoFile(String url);

  Future<void> removeVideo(String url);
}

class VideoCacheDataSourceImpl implements VideoCacheDataSource {
  VideoCacheDataSourceImpl({CacheManager? cacheManager})
    : _cacheManager = cacheManager ?? VideoCacheManager();

  final CacheManager _cacheManager;

  static const _fetchTimeout = Duration(seconds: 15);

  @override
  Future<File> getVideoFile(String url) async {
    try {
      return await _cacheManager
          .getSingleFile(url)
          .timeout(
            _fetchTimeout,
            onTimeout: () => throw TimeoutException(),
          );
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      rethrow;
    }
  }

  @override
  Future<void> removeVideo(String url) {
    return _cacheManager.removeFile(url);
  }
}

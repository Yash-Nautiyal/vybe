import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vybe/features/reels/data/datasources/video_cache_manager.dart';

/// Local disk cache for remote MP4 files.
abstract class VideoCacheDataSource {
  Future<File> getVideoFile(String url);
}

class VideoCacheDataSourceImpl implements VideoCacheDataSource {
  VideoCacheDataSourceImpl({CacheManager? cacheManager})
    : _cacheManager = cacheManager ?? VideoCacheManager();

  final CacheManager _cacheManager;

  @override
  Future<File> getVideoFile(String url) {
    return _cacheManager.getSingleFile(url);
  }
}

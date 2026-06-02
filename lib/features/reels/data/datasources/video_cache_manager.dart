import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// App-scoped video disk cache: 7-day staleness, max 50 MP4 files (~750MB).
class VideoCacheManager extends CacheManager {
  static const key = 'vybeVideoCache';

  static final VideoCacheManager _instance = VideoCacheManager._();
  factory VideoCacheManager() => _instance;

  VideoCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 50,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}

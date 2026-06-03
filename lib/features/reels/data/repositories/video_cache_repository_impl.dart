import 'package:vybe/features/reels/data/datasources/video_cache_manager.dart';
import 'package:vybe/features/reels/domain/repositories/video_cache_repository.dart';

class VideoCacheRepositoryImpl implements VideoCacheRepository {
  VideoCacheRepositoryImpl({VideoCacheManager? cacheManager})
    : _cacheManager = cacheManager ?? VideoCacheManager();

  final VideoCacheManager _cacheManager;

  @override
  Future<void> clearCache() => _cacheManager.emptyCache();
}

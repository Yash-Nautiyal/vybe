/// Contract for local video file caching.
abstract class VideoCacheRepository {
  Future<void> clearCache();
}

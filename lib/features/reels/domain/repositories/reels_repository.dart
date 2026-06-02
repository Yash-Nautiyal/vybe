import 'package:vybe/features/reels/domain/entities/video.dart';

/// Contract for fetching reel catalog data.
/// Implementation lives in the data layer.
abstract class ReelsRepository {
  Future<List<Video>> getReels();
}

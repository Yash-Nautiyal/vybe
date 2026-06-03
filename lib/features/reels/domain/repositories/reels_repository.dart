import 'package:vybe/features/reels/domain/entities/video.dart';

abstract class ReelsRepository {
  Future<List<Video>> getReels();
  Future<void> toggleLike({required String videoId, required bool like});
  Future<void> toggleStar({required String videoId, required bool star});
}

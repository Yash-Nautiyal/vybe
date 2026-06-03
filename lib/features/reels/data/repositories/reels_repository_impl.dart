import 'package:vybe/features/reels/data/datasources/reels_remote_datasource.dart';
import 'package:vybe/features/reels/data/datasources/reels_local_datasource.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';
import 'package:vybe/features/reels/domain/repositories/reels_repository.dart';

/// Maps data-layer models to domain entities.
class ReelsRepositoryImpl implements ReelsRepository {
  ReelsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final ReelsRemoteDataSource _remoteDataSource;
  final ReelsLocalDataSource _localDataSource;

  @override
  Future<List<Video>> getReels() async {
    final models = await _remoteDataSource.fetchVideos();
    final likedIds = await _localDataSource.getLikedVideoIds();
    final starredIds = await _localDataSource.getStarredVideoIds();

    return models.map((model) {
      final entity = model.toEntity();
      return entity.copyWith(
        liked: likedIds.contains(entity.id),
        starred: starredIds.contains(entity.id),
      );
    }).toList();
  }

  @override
  Future<void> toggleLike({required String videoId, required bool like}) async {
    await _localDataSource.setLiked(videoId, like);
    try {
      await _remoteDataSource.updateLikeCount(videoId, like ? 1 : -1);
    } catch (error) {
      await _localDataSource.setLiked(videoId, !like);
      rethrow;
    }
  }

  @override
  Future<void> toggleStar({required String videoId, required bool star}) async {
    await _localDataSource.setStarred(videoId, star);
    try {
      await _remoteDataSource.updateStarCount(videoId, star ? 1 : -1);
    } catch (error) {
      await _localDataSource.setStarred(videoId, !star);
      rethrow;
    }
  }
}

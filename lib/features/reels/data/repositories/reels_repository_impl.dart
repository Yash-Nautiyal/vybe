import 'package:vybe/features/reels/data/datasources/reels_remote_datasource.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';
import 'package:vybe/features/reels/domain/repositories/reels_repository.dart';

/// Maps data-layer models to domain entities.
class ReelsRepositoryImpl implements ReelsRepository {
  ReelsRepositoryImpl(this._remoteDataSource);

  final ReelsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Video>> getReels() async {
    final models = await _remoteDataSource.fetchVideos();
    return models.map((model) => model.toEntity()).toList();
  }
}

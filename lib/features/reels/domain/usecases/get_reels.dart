import 'package:vybe/core/error/error_mapper.dart';
import 'package:vybe/core/utils/result.dart';
import '../entities/video.dart';
import '../repositories/reels_repository.dart';

/// Fetches the reel feed from the domain repository.
class GetReels {
  const GetReels(this._repository);

  final ReelsRepository _repository;

  Future<Result<List<Video>>> call() async {
    try {
      final videos = await _repository.getReels();
      return Result.success(videos);
    } catch (error) {
      return Result.failure(mapToFailure(error));
    }
  }
}

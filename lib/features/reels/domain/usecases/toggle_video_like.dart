import 'package:vybe/core/error/error_mapper.dart';
import 'package:vybe/core/utils/result.dart';
import '../repositories/reels_repository.dart';

class ToggleVideoLike {
  const ToggleVideoLike(this._repository);

  final ReelsRepository _repository;

  Future<Result<void>> call({
    required String videoId,
    required bool like,
  }) async {
    try {
      await _repository.toggleLike(videoId: videoId, like: like);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapToFailure(error));
    }
  }
}

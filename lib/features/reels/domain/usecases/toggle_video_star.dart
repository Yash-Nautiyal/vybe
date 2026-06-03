import 'package:vybe/core/error/failures.dart';
import 'package:vybe/core/utils/result.dart';
import 'package:vybe/features/reels/domain/repositories/reels_repository.dart';

class ToggleVideoStar {
  const ToggleVideoStar(this._repository);

  final ReelsRepository _repository;

  Future<Result<void>> call({
    required String videoId,
    required bool star,
  }) async {
    try {
      await _repository.toggleStar(videoId: videoId, star: star);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(FirestoreFailure(error.toString()));
    }
  }
}

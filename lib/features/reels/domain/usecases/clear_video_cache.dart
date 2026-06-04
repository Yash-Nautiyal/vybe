import 'package:vybe/core/error/failures.dart';
import 'package:vybe/core/utils/result.dart';
import '../repositories/video_cache_repository.dart';

class ClearVideoCache {
  const ClearVideoCache(this._repository);

  final VideoCacheRepository _repository;

  Future<Result<void>> call() async {
    try {
      await _repository.clearCache();
      return const Result.success(null);
    } catch (error) {
      return Result.failure(CacheFailure(error.toString()));
    }
  }
}

import 'package:vybe/core/error/failures.dart';
import 'package:vybe/core/utils/result.dart';
import 'package:vybe/features/reels/domain/repositories/seed_repository.dart';

class ReseedVideos {
  const ReseedVideos(this._repository);

  final SeedRepository _repository;

  Future<Result<void>> call() async {
    try {
      await _repository.reseedVideos();
      return const Result.success(null);
    } catch (error) {
      return Result.failure(FirestoreFailure(error.toString()));
    }
  }
}

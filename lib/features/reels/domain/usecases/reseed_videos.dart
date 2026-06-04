import 'package:vybe/core/error/error_mapper.dart';
import 'package:vybe/core/utils/result.dart';
import '../repositories/seed_repository.dart';

class ReseedVideos {
  const ReseedVideos(this._repository);

  final SeedRepository _repository;

  Future<Result<void>> call() async {
    try {
      await _repository.reseedVideos();
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapToFailure(error));
    }
  }
}

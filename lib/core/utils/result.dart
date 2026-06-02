import '../error/failures.dart';

class Result<T> {
  final T? data;
  final AppFailure? failure;

  const Result.success(this.data) : failure = null;
  const Result.failure(this.failure) : data = null;

  bool get isSuccess => failure == null;
}
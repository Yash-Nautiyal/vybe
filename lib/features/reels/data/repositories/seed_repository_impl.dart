import 'package:vybe/features/reels/data/datasources/seed_local_datasource.dart';
import 'package:vybe/features/reels/domain/repositories/seed_repository.dart';

class SeedRepositoryImpl implements SeedRepository {
  SeedRepositoryImpl(this._localDataSource);

  final SeedLocalDataSource _localDataSource;

  @override
  Future<void> reseedVideos() => _localDataSource.reseedVideos();
}

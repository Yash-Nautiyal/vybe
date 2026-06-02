import 'package:vybe/seeder.dart';

abstract class SeedLocalDataSource {
  Future<void> reseedVideos();
}

class SeedLocalDataSourceImpl implements SeedLocalDataSource {
  @override
  Future<void> reseedVideos() => DatabaseSeeder.reseedVideos();
}

/// Contract for dev seed operations (Firestore catalog).
abstract class SeedRepository {
  Future<void> reseedVideos();
}

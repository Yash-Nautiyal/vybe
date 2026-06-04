import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/network/network_info.dart';
import 'package:vybe/core/network/network_request.dart';
import 'package:vybe/features/reels/data/models/video_model.dart';

abstract class ReelsRemoteDataSource {
  Future<List<VideoModel>> fetchVideos();
  Future<void> updateLikeCount(String videoId, int delta);
  Future<void> updateStarCount(String videoId, int delta);
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  ReelsRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    NetworkInfo? networkInfo,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _request = NetworkRequest(networkInfo ?? NetworkInfoImpl());

  final FirebaseFirestore _firestore;
  final NetworkRequest _request;

  static const _collection = 'videos';

  @override
  Future<List<VideoModel>> fetchVideos() {
    return _request.run(
      request: () async {
        final snapshot =
            await _firestore
                .collection(_collection)
                .orderBy('createdAt', descending: true)
                .get();

        return snapshot.docs.map(VideoModel.fromFirestore).toList();
      },
    );
  }

  @override
  Future<void> updateLikeCount(String videoId, int delta) {
    return _request.run(
      request:
          () => _firestore.collection(_collection).doc(videoId).update({
            'likes': FieldValue.increment(delta),
          }),
    );
  }

  @override
  Future<void> updateStarCount(String videoId, int delta) {
    return _request.run(
      request:
          () => _firestore.collection(_collection).doc(videoId).update({
            'starredCount': FieldValue.increment(delta),
          }),
    );
  }
}

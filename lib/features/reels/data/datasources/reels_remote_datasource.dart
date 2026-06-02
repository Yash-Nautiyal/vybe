import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/features/reels/data/models/video_model.dart';

abstract class ReelsRemoteDataSource {
  Future<List<VideoModel>> fetchVideos();
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  ReelsRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'videos';

  @override
  Future<List<VideoModel>> fetchVideos() async {
    final snapshot =
        await _firestore
            .collection(_collection)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map(VideoModel.fromFirestore).toList();
  }
}

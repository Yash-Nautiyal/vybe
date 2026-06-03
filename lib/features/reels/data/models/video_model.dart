import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

/// Firestore DTO — maps raw documents to domain [Video] entities.
class VideoModel {
  const VideoModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.likes,
    required this.comments,
    this.liked = false,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String username;
  final String userProfilePic;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final int likes;
  final int comments;
  final bool liked;
  final DateTime? createdAt;

  factory VideoModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return VideoModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      userProfilePic: data['userProfilePic'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      description: data['description'] as String? ?? '',
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      liked: data['liked'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Video toEntity() {
    return Video(
      id: id,
      userId: userId,
      username: username,
      userProfilePic: userProfilePic,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      description: description,
      likes: likes,
      comments: comments,
      liked: liked,
      createdAt: createdAt,
    );
  }
}

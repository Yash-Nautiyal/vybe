
class Video {
  const Video({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.likes,
    required this.comments,
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
  final DateTime? createdAt;
}

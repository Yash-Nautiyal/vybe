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
    required this.starredCount,
    this.liked = false,
    this.starred = false,
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
  final int starredCount;
  final bool liked;
  final bool starred;
  final DateTime? createdAt;

  Video copyWith({
    String? id,
    String? userId,
    String? username,
    String? userProfilePic,
    String? videoUrl,
    String? thumbnailUrl,
    String? description,
    int? likes,
    int? comments,
    int? starredCount,
    bool? liked,
    bool? starred,
    DateTime? createdAt,
  }) {
    return Video(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      starredCount: starredCount ?? this.starredCount,
      liked: liked ?? this.liked,
      starred: starred ?? this.starred,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Local profile for the signed-in user (no Firestore profile collection).
class UserProfile {
  const UserProfile({
    required this.username,
    required this.displayName,
    required this.profilePicUrl,
    required this.bio,
    required this.postCount,
    required this.repostCount,
    required this.followingCount,
    required this.friendsCount,
  });

  final String username;
  final String displayName;
  final String profilePicUrl;
  final String bio;
  final int postCount;
  final int repostCount;
  final int followingCount;
  final int friendsCount;

  static const demo = UserProfile(
    username: 'vybe_dev',
    displayName: 'VYbe Developer',
    profilePicUrl: 'https://i.pravatar.cc/300?img=8',
    bio:
        'Lifestyle enthusiast. Sharing positivity, travel, and daily moments. Let\'s grow together! 😊',
    postCount: 420,
    repostCount: 221,
    followingCount: 781,
    friendsCount: 352100,
  );

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? profilePicUrl,
    String? bio,
    int? postCount,
    int? repostCount,
    int? followingCount,
    int? friendsCount,
  }) {
    return UserProfile(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      bio: bio ?? this.bio,
      postCount: postCount ?? this.postCount,
      repostCount: repostCount ?? this.repostCount,
      followingCount: followingCount ?? this.followingCount,
      friendsCount: friendsCount ?? this.friendsCount,
    );
  }
}

import 'dart:math';

import 'package:vybe/features/profile/domain/entities/user_profile.dart';
import 'package:vybe/features/reels/data/datasources/reels_local_datasource.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

import 'profile_local_datasource.dart';

class ProfileComment {
  const ProfileComment({
    required this.text,
    required this.timeAgo,
    required this.postThumbnailUrl,
    required this.postUsername,
  });

  final String text;
  final String timeAgo;
  final String postThumbnailUrl;
  final String postUsername;
}

class ProfileContent {
  const ProfileContent({
    required this.profile,
    required this.posts,
    required this.starred,
    required this.comments,
  });

  final UserProfile profile;
  final List<Video> posts;
  final List<Video> starred;
  final List<ProfileComment> comments;
}

class ProfileContentLoader {
  ProfileContentLoader({
    ReelsLocalDataSource? interactionsLocal,
    ProfileLocalDataSource? profileLocal,
  }) : _interactionsLocal = interactionsLocal ?? ReelsLocalDataSourceImpl(),
       _profileLocal = profileLocal ?? ProfileLocalDataSourceImpl();

  final ReelsLocalDataSource _interactionsLocal;
  final ProfileLocalDataSource _profileLocal;

  static const _sampleComments = [
    'This is absolutely fire 🔥',
    'Love your content, keep it up!',
    'That transition was so smooth',
    'Couldn\'t stop watching this one 😍',
    'You inspire me every day',
    'How did you edit this? It\'s stunning',
    'Bro this hit different at 3am',
    'More of this please!!',
    'The vibe is immaculate ✨',
    'Saved this to my favorites ❤️',
  ];

  static const _samplePostUsernames = [
    'travel_vibes',
    'daily_moments',
    'creator_hub',
    'night_owl',
    'studio_flow',
    'city_lights',
  ];

  Future<ProfileContent> load(List<Video> videos) async {
    final allIds = videos.map((v) => v.id).toList();

    final postIds = await _profileLocal.getOrAssignPostVideoIds(allIds);
    final posts = _videosForIds(videos, postIds);

    final starredIds = await _interactionsLocal.getStarredVideoIds();
    final starred = _videosForIds(videos, starredIds.toList());

    const profile = UserProfile.demo;

    final comments = _buildComments(videos);

    return ProfileContent(
      profile: profile,
      posts: posts,
      starred: starred,
      comments: comments,
    );
  }

  List<Video> _videosForIds(List<Video> all, List<String> ids) {
    final byId = {for (final v in all) v.id: v};
    return [
      for (final id in ids)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  List<ProfileComment> _buildComments(List<Video> videos) {
    if (videos.isEmpty) {
      return List.generate(
        6,
        (i) => ProfileComment(
          text: _sampleComments[i % _sampleComments.length],
          timeAgo: '${i + 1}h ago',
          postThumbnailUrl: 'https://picsum.photos/seed/vybe_comment_$i/200/280',
          postUsername: _samplePostUsernames[i % _samplePostUsernames.length],
        ),
      );
    }

    final random = Random();
    final count = min(8, max(6, videos.length));
    return List.generate(count, (i) {
      final video = videos[random.nextInt(videos.length)];
      return ProfileComment(
        text: _sampleComments[random.nextInt(_sampleComments.length)],
        timeAgo: '${random.nextInt(12) + 1}h ago',
        postThumbnailUrl: video.thumbnailUrl,
        postUsername: video.username,
      );
    });
  }
}

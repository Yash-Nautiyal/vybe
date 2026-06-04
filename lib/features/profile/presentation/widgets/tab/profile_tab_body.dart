import 'package:flutter/material.dart';
import 'package:vybe/features/profile/data/profile_content_loader.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

import '../body/comment_body.dart';
import '../body/mentions_body.dart';
import '../body/post_body.dart';
import '../body/star_body.dart';

class ProfileTabBody extends StatelessWidget {
  const ProfileTabBody({
    super.key,
    required this.content,
    required this.onVideoSelected,
  });

  final ProfileContent content;
  final ValueChanged<Video> onVideoSelected;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        PostsBody(videos: content.posts, onVideoSelected: onVideoSelected),
        CommentsBody(comments: content.comments),
        StarsBody(videos: content.starred, onVideoSelected: onVideoSelected),
        const MentionsBody(),
      ],
    );
  }
}

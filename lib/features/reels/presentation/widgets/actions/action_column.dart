import 'package:flutter/material.dart';
import 'package:vybe/core/helpers/reel_count_helper.dart';

import 'action_button.dart';

class ActionColumn extends StatelessWidget {
  const ActionColumn({
    super.key,
    required this.likes,
    required this.comments,
    required this.liked,
    required this.starred,
    required this.starredCount,
    this.onLike,
    this.onStar,
  });

  final int likes;
  final int comments;
  final bool liked;
  final bool starred;
  final int starredCount;
  final VoidCallback? onLike;
  final VoidCallback? onStar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActionButton.like(
          liked: liked,
          label: formatCount(likes),
          onClick: onLike,
        ),
        const SizedBox(height: 20),
        ActionButton.comment(label: formatCount(comments)),
        const SizedBox(height: 20),
        const ActionButton.share(label: 'Share'),
        const SizedBox(height: 20),
        ActionButton.star(
          starred: starred,
          label: starredCount > 0 ? formatCount(starredCount) : '',
          onClick: onStar,
        ),
      ],
    );
  }
}

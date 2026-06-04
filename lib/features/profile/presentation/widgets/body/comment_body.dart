import 'package:flutter/material.dart';
import 'package:vybe/core/constants/app_icons.dart';
import 'package:vybe/core/widgets/empty/empty_content.dart';
import 'package:vybe/features/profile/data/profile_content_loader.dart';

import '../ui/comment_tile.dart';

class CommentsBody extends StatelessWidget {
  const CommentsBody({super.key, required this.comments});

  final List<ProfileComment> comments;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const EmptyContent(
        icon: AppIcons.emptyChatIcon,
        title: 'No comments yet',
        description: 'Comments you leave on posts will show up here',
      );
    }

    final colors = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: comments.length,
      separatorBuilder:
          (_, __) => Divider(
            height: 1,
            color: colors.outlineVariant,
            indent: 16,
            endIndent: 16,
          ),
      itemBuilder: (context, index) => CommentTile(item: comments[index]),
    );
  }
}

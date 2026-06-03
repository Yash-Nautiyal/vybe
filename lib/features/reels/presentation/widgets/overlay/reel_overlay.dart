import 'package:flutter/material.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

import '../actions/action_column.dart';
import 'reel_info.dart';

class ReelOverlay extends StatelessWidget {
  const ReelOverlay({super.key, required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: ReelInfo(video: video)),
                const SizedBox(width: 16),
                ActionColumn(
                  likes: video.likes,
                  comments: video.comments,
                  liked: video.liked,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

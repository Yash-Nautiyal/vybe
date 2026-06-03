import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_bloc.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_event.dart';

import '../actions/action_column.dart';
import 'reel_info.dart';

class ReelOverlay extends StatelessWidget {
  const ReelOverlay({
    super.key,
    required this.video,
    required this.expandedNotifier,
  });

  final Video video;
  final ValueNotifier<bool> expandedNotifier;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ReelInfo(
                    video: video,
                    expandedNotifier: expandedNotifier,
                  ),
                ),
                const SizedBox(width: 16),
                ActionColumn(
                  likes: video.likes,
                  comments: video.comments,
                  liked: video.liked,
                  starred: video.starred,
                  starredCount: video.starredCount,
                  onLike:
                      () => context.read<ReelsBloc>().add(
                        ReelLikeToggled(video.id),
                      ),
                  onStar:
                      () => context.read<ReelsBloc>().add(
                        ReelStarToggled(video.id),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

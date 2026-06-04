import 'package:flutter/material.dart';
import 'package:vybe/core/constants/app_icons.dart';
import 'package:vybe/core/widgets/empty/empty_content.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

import '../ui/video_grid_tile.dart';

class StarsBody extends StatelessWidget {
  const StarsBody({
    super.key,
    required this.videos,
    required this.onVideoSelected,
  });

  final List<Video> videos;
  final ValueChanged<Video> onVideoSelected;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const EmptyContent(
        icon: AppIcons.emptyFolderIcon,
        title: 'Star reels to see them here',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoGridTile(
          video: video,
          onTap: () => onVideoSelected(video),
        );
      },
    );
  }
}

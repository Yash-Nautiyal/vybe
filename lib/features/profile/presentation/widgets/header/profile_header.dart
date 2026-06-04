import 'package:flutter/material.dart';
import 'package:vybe/features/profile/domain/entities/user_profile.dart';

import '../tab/profile_tab_bar.dart';
import 'avatar_section.dart';
import 'stats_row.dart';
import 'top_header.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile, this.onBack});

  final UserProfile profile;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            TopHeader(onBack: onBack),
            AvatarSection(profile: profile),
            const SizedBox(height: 20),
            StatsRow(profile: profile),
            const SizedBox(height: 12),
            const ProfileTabBar(),
          ],
        ),
      ),
    );
  }
}

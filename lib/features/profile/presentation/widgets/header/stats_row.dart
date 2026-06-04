import 'package:flutter/material.dart';
import 'package:vybe/core/helpers/reel_count_helper.dart';
import 'package:vybe/features/profile/domain/entities/user_profile.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatItem(value: profile.postCount, label: 'Post'),
            ),
            _StatDivider(color: colors.outlineVariant),
            Expanded(
              child: _StatItem(value: profile.repostCount, label: 'Repost'),
            ),
            _StatDivider(color: colors.outlineVariant),
            Expanded(
              child: _StatItem(
                value: profile.followingCount,
                label: 'Following',
              ),
            ),
            _StatDivider(color: colors.outlineVariant),
            Expanded(
              child: _StatItem(value: profile.friendsCount, label: 'Friends'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatCount(value),
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(width: 1, thickness: 1, color: color);
  }
}

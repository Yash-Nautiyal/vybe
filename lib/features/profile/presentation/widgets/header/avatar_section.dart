import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vybe/core/constants/app_icons.dart';
import 'package:vybe/core/theme/app_pallete.dart';
import 'package:vybe/core/widgets/icon/app_svg_icon.dart';
import 'package:vybe/features/profile/domain/entities/user_profile.dart';

class AvatarSection extends StatelessWidget {
  const AvatarSection({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.outline, width: 1),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(profile.profilePicUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2.5,
                    ),
                  ),
                  child: const Center(
                    child: AppSvgIcon(
                      asset: AppIcons.profileEditIcon,
                      size: 12,
                      color: AppPallete.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(profile.username, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            profile.displayName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.bio,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

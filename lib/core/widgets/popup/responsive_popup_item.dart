import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../constants/app_icons.dart';
import 'responsive_popup.dart';

import '../divider/custom_divider.dart';

class ResponsivePopupItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? svgIcon;
  final VoidCallback onTap;
  final Color? color;

  const ResponsivePopupItem({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.color,
    this.svgIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: color ?? Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 10),
          ],
          if (svgIcon != null) ...[
            SvgPicture.asset(
              svgIcon!,
              width: 20,
              color: color ?? Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class DestructivePopupItem extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String svgIcon;
  final Color color;
  final ResponsivePopupController? popupController;
  const DestructivePopupItem({
    super.key,
    required this.onTap,
    this.title = 'Delete',
    this.svgIcon = AppIcons.trashBoldIcon,
    this.color = Colors.red,
    this.popupController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        CustomDivider(color: theme.dividerColor.withAlpha(100), dashWidth: 2.3),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ResponsivePopupItem(
            title: title,
            svgIcon: svgIcon,
            color: color,
            onTap: () {
              popupController?.hide();
              onTap();
            },
          ),
        ),
      ],
    );
  }
}

// class ViewPopupItem extends ResponsivePopupItem {
//   const ViewPopupItem({
//     super.key,
//     super.title = 'View',
//     required super.onTap,
//     super.svgIcon = 'assets/icons/common/solid/ic-solar_eye-bold.svg',
//     super.color,
//   });
// }

class EditPopupItem extends ResponsivePopupItem {
  const EditPopupItem({
    super.key,
    super.title = 'Edit',
    required super.onTap,
    super.svgIcon = AppIcons.penBoldIcon,
    super.color,
  });
}

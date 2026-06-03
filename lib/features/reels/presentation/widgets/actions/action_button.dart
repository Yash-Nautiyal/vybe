import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/constants/app_icons.dart';

enum ActionButtonType { like, comment, share, star }

class ActionButton extends StatelessWidget {
  const ActionButton.like({
    super.key,
    required this.liked,
    required this.label,
    this.onClick,
  }) : type = ActionButtonType.like,
       icon = AppIcons.heartLinearIcon,
       starred = null;

  const ActionButton.comment({super.key, required this.label, this.onClick})
    : type = ActionButtonType.comment,
      icon = AppIcons.chatLinearIcon,
      liked = null,
      starred = null;

  const ActionButton.share({super.key, required this.label, this.onClick})
    : type = ActionButtonType.share,
      icon = AppIcons.shareLinearIcon,
      liked = null,
      starred = null;

  const ActionButton.star({
    super.key,
    required this.label,
    required this.starred,
    this.onClick,
  }) : type = ActionButtonType.star,
       icon = AppIcons.starLinearIcon,
       liked = null;

  final String icon;
  final String label;
  final ActionButtonType type;
  final bool? liked;
  final bool? starred;
  final VoidCallback? onClick;

  Color _iconColor(ColorScheme colors) {
    if (type == ActionButtonType.like && liked == true) {
      return colors.primary;
    }
    if (type == ActionButtonType.star && starred == true) {
      return colors.secondary;
    }
    return colors.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final iconColor = _iconColor(colors);

    final content = Column(
      children: [
        SvgPicture.asset(
          icon,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          width: 30,
          height: 30,
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color:
                type == ActionButtonType.like && liked == true
                    ? colors.primary
                    : null,
          ),
        ),
      ],
    );

    if (onClick == null) return content;

    return GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

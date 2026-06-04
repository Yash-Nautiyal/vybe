import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyContent extends StatelessWidget {
  final String icon;
  final String? title;
  final String? description;
  const EmptyContent({
    super.key,
    required this.icon,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon),
          title != null
              ? Text(
                title!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              )
              : const SizedBox.shrink(),
          description != null
              ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon({
    super.key,
    required this.asset,
    this.size = 22,
    this.color,
    this.onTap,
    this.semanticLabel,
    this.padding = EdgeInsets.zero,
  });

  final String asset;
  final double size;
  final Color? color;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Widget icon = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );

    if (semanticLabel != null) {
      icon = Semantics(label: semanticLabel, button: onTap != null, child: icon);
    }

    icon = Padding(padding: padding, child: icon);

    if (onTap == null) return icon;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: icon,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vybe/core/constants/app_icons.dart';

class DoubleTapHeart extends StatelessWidget {
  const DoubleTapHeart({
    super.key,
    required this.position,
    required this.controller,
    required this.scaleAnim,
    required this.opacityAnim,
  });

  final Offset position;
  final AnimationController controller;
  final Animation<double> scaleAnim;
  final Animation<double> opacityAnim;

  @override
  Widget build(BuildContext context) {
    const size = 110.0;
    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder:
              (_, child) => Opacity(
                opacity: opacityAnim.value,
                child: Transform.scale(scale: scaleAnim.value, child: child),
              ),
          child: SvgPicture.asset(
            AppIcons.heartBoldIcon,
            width: size,
            height: size,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final Widget child;
  final Function onClick;
  final Color? backgroundColor;
  final double? padding;
  const CustomTextButton({
    super.key,
    required this.child,
    required this.onClick,
    this.backgroundColor,
    this.padding = 4,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => onClick(),
        style: backgroundColor != null
            ? ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(backgroundColor),
                side: const WidgetStatePropertyAll(BorderSide.none))
            : null,
        child: Padding(
          padding: EdgeInsets.all(padding!),
          child: child,
        ));
  }
}

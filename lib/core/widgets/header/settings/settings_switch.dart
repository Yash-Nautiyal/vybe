import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsSwitch extends StatelessWidget {
  final String icon;
  final String title;
  final ThemeData theme;
  final Function() onSwitch;

  const SettingsSwitch({
    super.key,
    required this.theme,
    required this.icon,
    required this.title,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.disabledColor.withAlpha(100)),
      ),
      height: 100,
      padding: const EdgeInsets.only(left: 15, right: 0, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                icon,
                colorFilter:
                    theme.brightness == Brightness.dark
                        ? ColorFilter.mode(theme.disabledColor, BlendMode.srcIn)
                        : null,
              ),
              const SizedBox(width: 50),
              Transform.scale(
                scale: 0.65,
                child: Switch(
                  value: theme.brightness == Brightness.dark,
                  onChanged: (_) => onSwitch(),
                ),
              ),
            ],
          ),
          Text(title, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

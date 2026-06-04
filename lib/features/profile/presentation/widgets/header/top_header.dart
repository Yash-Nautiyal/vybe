import 'package:flutter/material.dart';
import 'package:vybe/core/widgets/header/settings/settings.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
        child: SizedBox(
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: onSurface,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
              Text('Profile', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

void showSettingsDialog(BuildContext context) {
  Navigator.of(context).push<void>(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => const SettingsDialog(),
    ),
  );
}

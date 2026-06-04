import 'package:flutter/material.dart';

class BufferingBanner extends StatelessWidget {
  const BufferingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 96),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainer.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Reconnecting...', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
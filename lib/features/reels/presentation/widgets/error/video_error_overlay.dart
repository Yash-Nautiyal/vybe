import 'package:flutter/material.dart';
import 'package:vybe/core/error/failures.dart';

class VideoErrorOverlay extends StatelessWidget {
  const VideoErrorOverlay({super.key, required this.failure, this.onRetry});

  final AppFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ColoredBox(color: colors.scrim.withValues(alpha: 0.65)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: colors.onSurface,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  failure.message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Tap to Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
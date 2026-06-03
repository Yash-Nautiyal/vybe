import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vybe/core/constants/app_icons.dart';
import 'package:vybe/core/widgets/button/custom_textbutton.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.alertIcon,
              color: theme.colorScheme.error,
              width: 48,
            ),
            const SizedBox(height: 16),
            Text('Could not load reels', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            CustomTextButton(onClick: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

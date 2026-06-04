import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_icons.dart';
import '../../error/messages/execption_messages.dart';
import '../../theme/app_pallete.dart';
import '../../theme/app_typography.dart';
import '../button/custom_textbutton.dart';

class OfflineLaunchView extends StatelessWidget {
  const OfflineLaunchView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.offlineIllustration,
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 32),
              Text(
                'You\'re offline',
                style: AppTypography.headingSmall.copyWith(
                  color: AppPallete.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppExceptionMessages.noInternet,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppPallete.grey700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomTextButton(
                onClick: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

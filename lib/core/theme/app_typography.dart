import 'package:flutter/material.dart';

class AppTypography {
  static const String primaryFont = 'Public Sans';
  static const String secondaryFont = 'Barlow';

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  static const TextStyle headingLarge = TextStyle(
    fontFamily: secondaryFont,
    fontWeight: extraBold,
    fontSize: 40,
    height: 80 / 64,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: secondaryFont,
    fontWeight: extraBold,
    fontSize: 32,
    height: 64 / 48,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: secondaryFont,
    fontWeight: bold,
    fontSize: 24,
    height: 1.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontWeight: semiBold,
    fontSize: 20,
    height: 1.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontWeight: semiBold,
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontWeight: semiBold,
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(fontSize: 16, height: 1.5);

  static const TextStyle bodyMedium = TextStyle(fontSize: 14, height: 22 / 14);

  static const TextStyle bodySmall = TextStyle(fontSize: 12, height: 1.5);

  static const TextStyle labelLarge = TextStyle(
    fontWeight: bold,
    fontSize: 14,
    height: 24 / 14,
  );

  static const TextStyle labelMedium = TextStyle(
    fontWeight: bold,
    fontSize: 12,
    height: 24 / 14,
  );
  static const TextStyle labelSmall = TextStyle(
    fontWeight: bold,
    fontSize: 10,
    height: 24 / 14,
  );
}

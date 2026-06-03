import 'package:flutter/material.dart';

class AppTypography {
  static const String primaryFont = 'Quicksand';
  static const String displayFont = 'Barlow Condensed';

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  static const TextStyle headingLarge = TextStyle(
    fontFamily: displayFont,
    fontWeight: black,
    fontSize: 40,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: displayFont,
    fontWeight: extraBold,
    fontSize: 32,
    height: 1.15,
    letterSpacing: -0.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: displayFont,
    fontWeight: bold,
    fontSize: 24,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFont,
    fontWeight: semiBold,
    fontSize: 20,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontWeight: semiBold,
    fontSize: 16,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFont,
    fontWeight: semiBold,
    fontSize: 14,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    height: 1.5,
    fontWeight: regular,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    height: 1.57,
    fontWeight: regular,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    height: 1.5,
    fontWeight: regular,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFont,
    fontWeight: bold,
    fontSize: 14,
    height: 1.71,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFont,
    fontWeight: bold,
    fontSize: 12,
    height: 2.0,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFont,
    fontWeight: bold,
    fontSize: 10,
    height: 2.0,
    letterSpacing: 0.2,
  );
}

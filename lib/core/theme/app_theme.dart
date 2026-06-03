import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './app_typography.dart';
import './app_pallete.dart';

class AppTheme {
  static ThemeData darkTheme = buildTheme();
}

ThemeData buildTheme() {
  final baseTextTheme = TextTheme(
    displayLarge: AppTypography.headingLarge.copyWith(color: AppPallete.white),
    displayMedium: AppTypography.headingMedium.copyWith(
      color: AppPallete.white,
    ),
    displaySmall: AppTypography.headingSmall.copyWith(color: AppPallete.white),
    titleLarge: AppTypography.titleLarge.copyWith(color: AppPallete.white),
    titleMedium: AppTypography.titleMedium.copyWith(color: AppPallete.white),
    titleSmall: AppTypography.titleSmall.copyWith(color: AppPallete.white),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: AppPallete.white),
    bodyMedium: AppTypography.bodyMedium.copyWith(color: AppPallete.grey700),
    bodySmall: AppTypography.bodySmall.copyWith(color: AppPallete.grey600),
    labelLarge: AppTypography.labelLarge.copyWith(color: AppPallete.white),
    labelMedium: AppTypography.labelMedium.copyWith(color: AppPallete.white),
    labelSmall: AppTypography.labelSmall.copyWith(color: AppPallete.grey700),
  );

  final googleTextTheme = GoogleFonts.getTextTheme(
    AppTypography.primaryFont,
    baseTextTheme,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppPallete.primaryMain,

    scaffoldBackgroundColor: AppPallete.scaffoldBg,
    dividerColor: AppPallete.grey300,
    disabledColor: AppPallete.grey500,
    cardColor: AppPallete.cardBg,
    shadowColor: AppPallete.black.withOpacity(0.6),
    indicatorColor: AppPallete.primaryMain,
    hoverColor: AppPallete.grey200,

    // Text Theme
    fontFamily: AppTypography.primaryFont,
    textTheme: googleTextTheme,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppPallete.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppPallete.primaryMain,
      primaryFixedDim: AppPallete.primaryLight,
      primaryContainer: AppPallete.primaryDarker,
      onPrimary: AppPallete.white,
      secondary: AppPallete.secondaryMain,
      secondaryFixedDim: AppPallete.secondaryLight,
      secondaryContainer: AppPallete.secondaryDarker,
      onSecondary: AppPallete.white,
      error: AppPallete.errorMain,
      errorContainer: AppPallete.errorDark,
      surface: AppPallete.cardBg,
      onSurface: AppPallete.white,
      tertiary: AppPallete.white,
      surfaceContainer: AppPallete.containerColor,
      surfaceDim: AppPallete.grey300,
      outline: AppPallete.grey400,
    ),

    // TextField
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPallete.containerColor,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppPallete.grey500),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppPallete.grey400, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppPallete.primaryMain, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Elevated Button (main CTA — red-orange filled)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(AppPallete.primaryMain),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        textStyle: WidgetStatePropertyAll(AppTypography.labelLarge),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),

    // Text Button (outlined / ghost style)
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppPallete.primaryMain),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: AppPallete.grey400, width: 1.5),
          ),
        ),
        textStyle: WidgetStatePropertyAll(AppTypography.labelLarge),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppPallete.white),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppPallete.grey400, width: 1.5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPallete.overlayDark,
      selectedItemColor: AppPallete.primaryMain,
      unselectedItemColor: AppPallete.grey600,
      type: BottomNavigationBarType.fixed,
    ),

    // Navigation Bar (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppPallete.overlayDark,
      indicatorColor: AppPallete.primaryMain.withOpacity(0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppPallete.primaryMain);
        }
        return const IconThemeData(color: AppPallete.grey600);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(
            color: AppPallete.primaryMain,
          );
        }
        return AppTypography.labelSmall.copyWith(color: AppPallete.grey600);
      }),
    ),

    // Tab Bar
    tabBarTheme: const TabBarTheme(
      labelColor: AppPallete.primaryMain,
      unselectedLabelColor: AppPallete.grey600,
      indicatorColor: AppPallete.primaryMain,
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppPallete.grey500, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.primaryMain;
        }
        return Colors.transparent;
      }),
    ),

    // Radio
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.primaryMain;
        }
        return AppPallete.grey500;
      }),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.white;
        }
        return AppPallete.grey600;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.primaryMain;
        }
        return AppPallete.grey400;
      }),
    ),

    // Icon Button
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(5)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppPallete.containerColor,
      selectedColor: AppPallete.primaryMain.withOpacity(0.2),
      labelStyle: AppTypography.labelMedium.copyWith(color: AppPallete.white),
      side: const BorderSide(color: AppPallete.grey400, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      checkmarkColor: AppPallete.primaryMain,
    ),

    // Card
    cardTheme: CardTheme(
      color: AppPallete.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
    ),

    // Slider
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppPallete.primaryMain,
      inactiveTrackColor: AppPallete.grey400,
      thumbColor: AppPallete.primaryMain,
      overlayColor: Color(0x29E8341C),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppPallete.primaryMain,
      linearTrackColor: AppPallete.grey300,
    ),

    // TimePicker
    timePickerTheme: TimePickerThemeData(
      confirmButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: const WidgetStatePropertyAll(AppPallete.primaryMain),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.white),
      ),
      cancelButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.grey500),
      ),
    ),

    // DatePicker
    datePickerTheme: DatePickerThemeData(
      dividerColor: AppPallete.grey400,
      dayStyle: AppTypography.bodyMedium,
      headerHeadlineStyle: AppTypography.headingMedium,
      yearStyle: AppTypography.bodyMedium,
      weekdayStyle: AppTypography.bodyMedium,
      confirmButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: const WidgetStatePropertyAll(AppPallete.primaryMain),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.white),
      ),
      cancelButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.grey500),
      ),
      rangeSelectionBackgroundColor: Color(0x29E8341C),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPallete.containerColor,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppPallete.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog
    dialogTheme: DialogTheme(
      backgroundColor: AppPallete.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppPallete.white,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppPallete.grey700,
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppPallete.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Popup Menu
    popupMenuTheme: PopupMenuThemeData(
      color: AppPallete.containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTypography.bodyMedium.copyWith(color: AppPallete.white),
    ),

    // List Tile
    listTileTheme: const ListTileThemeData(
      iconColor: AppPallete.grey700,
      textColor: AppPallete.white,
      tileColor: Colors.transparent,
    ),
  );
}

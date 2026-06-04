import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './app_typography.dart';
import './app_pallete.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData fallbackDarkTheme = _buildTheme(
    brightness: Brightness.dark,
    useGoogleFonts: false,
  );

  static final ThemeData fallbackLightTheme = _buildTheme(
    brightness: Brightness.light,
    useGoogleFonts: false,
  );

  static Future<ThemeData> loadDarkTheme() => _loadTheme(Brightness.dark);

  static Future<ThemeData> loadLightTheme() => _loadTheme(Brightness.light);

  static Future<ThemeData> _loadTheme(Brightness brightness) async {
    GoogleFonts.config.allowRuntimeFetching = true;
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.quicksand(),
        GoogleFonts.barlowCondensed(),
      ]);
      return _buildTheme(brightness: brightness, useGoogleFonts: true);
    } catch (_) {
      GoogleFonts.config.allowRuntimeFetching = false;
      return brightness == Brightness.dark
          ? fallbackDarkTheme
          : fallbackLightTheme;
    }
  }
}

ThemeData _buildTheme({
  required Brightness brightness,
  required bool useGoogleFonts,
}) {
  final isDark = brightness == Brightness.dark;

  final onSurface =
      isDark ? AppPallete.white : AppPallete.lightTextPrimary;
  final onSurfaceVariant =
      isDark ? AppPallete.grey700 : AppPallete.lightTextSecondary;
  final onSurfaceMuted =
      isDark ? AppPallete.grey600 : AppPallete.lightTextMuted;
  final scaffoldBg =
      isDark ? AppPallete.scaffoldBg : AppPallete.lightScaffoldBg;
  final cardBg = isDark ? AppPallete.cardBg : AppPallete.lightCardBg;
  final containerColor =
      isDark ? AppPallete.containerColor : AppPallete.lightContainer;
  final dividerColor = isDark ? AppPallete.grey300 : AppPallete.lightDivider;
  final outlineColor = isDark ? AppPallete.grey400 : AppPallete.lightBorder;
  final tabInactive =
      isDark ? AppPallete.grey600 : AppPallete.lightTextSecondary;
  final tabActive = isDark ? AppPallete.primaryMain : AppPallete.black;

  final baseTextTheme = TextTheme(
    displayLarge: AppTypography.headingLarge.copyWith(color: onSurface),
    displayMedium: AppTypography.headingMedium.copyWith(color: onSurface),
    displaySmall: AppTypography.headingSmall.copyWith(color: onSurface),
    titleLarge: AppTypography.titleLarge.copyWith(
      color: onSurface,
      fontWeight: isDark ? AppTypography.bold : AppTypography.bold,
      fontSize: isDark ? AppTypography.titleLarge.fontSize : 20,
    ),
    titleMedium: AppTypography.titleMedium.copyWith(
      color: onSurface,
      fontWeight: AppTypography.bold,
      fontSize: isDark ? AppTypography.titleMedium.fontSize : 17,
      letterSpacing: isDark ? null : -0.2,
    ),
    titleSmall: AppTypography.titleSmall.copyWith(color: onSurface),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: onSurface),
    bodyMedium: AppTypography.bodyMedium.copyWith(
      color: isDark ? AppPallete.grey700 : AppPallete.lightTextMuted,
      fontWeight: isDark ? AppTypography.regular : AppTypography.regular,
      height: isDark ? AppTypography.bodyMedium.height : 1.45,
    ),
    bodySmall: AppTypography.bodySmall.copyWith(color: onSurfaceMuted),
    labelLarge: AppTypography.labelLarge.copyWith(
      color: onSurface,
      fontWeight: AppTypography.semiBold,
    ),
    labelMedium: AppTypography.labelMedium.copyWith(color: onSurface),
    labelSmall: AppTypography.labelSmall.copyWith(
      color: isDark ? AppPallete.grey700 : AppPallete.lightTextSecondary,
      fontSize: isDark ? AppTypography.labelSmall.fontSize : 12,
    ),
  );

  final textTheme =
      useGoogleFonts
          ? GoogleFonts.getTextTheme(AppTypography.primaryFont, baseTextTheme)
          : baseTextTheme;

  final colorScheme =
      isDark
          ? ColorScheme.dark(
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
            surface: cardBg,
            onSurface: onSurface,
            onSurfaceVariant: onSurfaceVariant,
            tertiary: AppPallete.white,
            surfaceContainer: containerColor,
            surfaceDim: AppPallete.grey300,
            outline: outlineColor,
            outlineVariant: dividerColor,
          )
          : ColorScheme.light(
            primary: AppPallete.primaryMain,
            onPrimary: AppPallete.white,
            secondary: AppPallete.secondaryMain,
            onSecondary: AppPallete.white,
            error: AppPallete.editBadge,
            errorContainer: AppPallete.errorLighter,
            surface: scaffoldBg,
            onSurface: onSurface,
            onSurfaceVariant: onSurfaceVariant,
            surfaceContainer: containerColor,
            surfaceContainerHighest: AppPallete.lightContainer,
            outline: outlineColor,
            outlineVariant: dividerColor,
          );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    primaryColor: AppPallete.primaryMain,
    scaffoldBackgroundColor: scaffoldBg,
    dividerColor: dividerColor,
    disabledColor: isDark ? AppPallete.grey500 : AppPallete.lightTextSecondary,
    cardColor: cardBg,
    shadowColor:
        isDark ? AppPallete.black.withOpacity(0.6) : AppPallete.lightShadow,
    indicatorColor: tabActive,
    hoverColor: isDark ? AppPallete.grey200 : AppPallete.lightContainer,
    fontFamily: useGoogleFonts ? AppTypography.primaryFont : null,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: onSurface),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    ),
    colorScheme: colorScheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: containerColor,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppPallete.grey500 : AppPallete.lightTextSecondary,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: outlineColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppPallete.primaryMain, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
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
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppPallete.primaryMain),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: outlineColor, width: 1.5),
          ),
        ),
        textStyle: WidgetStatePropertyAll(AppTypography.labelLarge),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(onSurface),
        side: WidgetStatePropertyAll(
          BorderSide(color: outlineColor, width: 1.5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppPallete.overlayDark : scaffoldBg,
      selectedItemColor: AppPallete.primaryMain,
      unselectedItemColor: tabInactive,
      type: BottomNavigationBarType.fixed,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? AppPallete.overlayDark : scaffoldBg,
      indicatorColor: AppPallete.primaryMain.withOpacity(0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppPallete.primaryMain);
        }
        return IconThemeData(color: tabInactive);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(
            color: AppPallete.primaryMain,
          );
        }
        return AppTypography.labelSmall.copyWith(color: tabInactive);
      }),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: tabActive,
      unselectedLabelColor: tabInactive,
      indicatorColor: tabActive,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: dividerColor,
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(
        color: isDark ? AppPallete.grey500 : AppPallete.lightTextSecondary,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.primaryMain;
        }
        return Colors.transparent;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.primaryMain;
        }
        return isDark ? AppPallete.grey500 : AppPallete.lightTextSecondary;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.white;
        }
        return tabInactive;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppPallete.primaryMain;
        }
        return outlineColor;
      }),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(5)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: containerColor,
      selectedColor: AppPallete.primaryMain.withOpacity(0.2),
      labelStyle: AppTypography.labelMedium.copyWith(color: onSurface),
      side: BorderSide(color: outlineColor, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      checkmarkColor: AppPallete.primaryMain,
    ),
    cardTheme: CardTheme(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppPallete.primaryMain,
      inactiveTrackColor: AppPallete.grey400,
      thumbColor: AppPallete.primaryMain,
      overlayColor: Color(0x29E8341C),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppPallete.primaryMain,
      linearTrackColor: dividerColor,
    ),
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
        foregroundColor: WidgetStatePropertyAll(
          isDark ? AppPallete.grey500 : AppPallete.lightTextSecondary,
        ),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      dividerColor: outlineColor,
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
        foregroundColor: WidgetStatePropertyAll(
          isDark ? AppPallete.grey500 : AppPallete.lightTextSecondary,
        ),
      ),
      rangeSelectionBackgroundColor: const Color(0x29E8341C),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: containerColor,
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: AppTypography.titleLarge.copyWith(color: onSurface),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: onSurfaceVariant,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTypography.bodyMedium.copyWith(color: onSurface),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: onSurfaceVariant,
      textColor: onSurface,
      tileColor: Colors.transparent,
    ),
  );
}

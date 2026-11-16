import 'package:flutter/material.dart';

/// Design tokens from apps/CLAUDE.md. Do not add a colour, spacing, or type
/// size here without checking that file first.
class AppColors {
  AppColors._();

  static const forest900 = Color(0xFF123F2A);
  static const forest700 = Color(0xFF1B5E3B);
  static const gold500 = Color(0xFFC8A24A);
  static const cream100 = Color(0xFFFBF4E4);
  static const ink900 = Color(0xFF1F1F1F);
  static const ink500 = Color(0xFF6B6B6B);

  /// Placeholder pending the brand error red (apps/CLAUDE.md: "not chosen
  /// yet"). Material 3 baseline error colour, swap when a real one lands.
  static const errorPlaceholder = Color(0xFFB3261E);
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

class AppFontSizes {
  AppFontSizes._();

  static const caption = 12.0;
  static const small = 14.0;
  static const body = 16.0;
  static const subtitle = 20.0;
  static const title = 26.0;
  static const display = 34.0;
}

/// Minimum touch target for the farmer app (apps/CLAUDE.md: >= 48dp, no
/// exceptions).
const double kMinTouchTarget = 48.0;

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.forest700,
    primary: AppColors.forest700,
    secondary: AppColors.gold500,
    error: AppColors.errorPlaceholder,
    surface: AppColors.cream100,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.forest900,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: AppFontSizes.body, color: AppColors.ink900),
      bodyLarge: TextStyle(fontSize: AppFontSizes.body, color: AppColors.ink900),
      titleLarge: TextStyle(fontSize: AppFontSizes.title, color: AppColors.ink900),
      titleMedium: TextStyle(fontSize: AppFontSizes.subtitle, color: AppColors.ink900),
      labelLarge: TextStyle(fontSize: AppFontSizes.body, color: AppColors.ink900),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.forest700,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(kMinTouchTarget),
        textStyle: const TextStyle(fontSize: AppFontSizes.body, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cream100,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.lg)),
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}

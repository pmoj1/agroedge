import 'package:flutter/material.dart';

/// Design tokens from apps/CLAUDE.md. Do not add a colour, spacing, or type
/// size here without checking that file first.
class AppColors {
  AppColors._();

  // ── Core brand ──────────────────────────────────────────────────────────
  static const forest900 = Color(0xFF0F3020); // Deep pine — dark surfaces
  static const forest700 = Color(0xFF164E33); // Primary brand, CTAs, success
  static const forest500 = Color(0xFF2A7D52); // Interactive hover / mid accent
  static const forest100 = Color(0xFFEAF4EE); // Light soft green shade
  static const gold600 = Color(0xFFA67C2E); // Deep ochre — emphasis borders
  static const gold500 = Color(0xFFBD943A); // Ochre accent — warnings, badges
  static const gold200 = Color(0xFFF5E6C0); // Warm highlight fill

  // ── Data-vis secondaries ─────────────────────────────────────────────────
  static const clay400 = Color(0xFFC4896A); // Terracotta — African warmth
  static const sky400 = Color(0xFF4A9BB8); // Map water / chart secondary

  // ── Neutral scale ────────────────────────────────────────────────────────
  static const cream100 = Color(0xFFF7F2E6); // Silk cream light surface
  static const ink900 = Color(0xFF1A1C1A); // Body text
  static const ink500 = Color(0xFF5F6660); // Secondary / label text
  static const ink200 = Color(0xFFD4D8D5); // Dividers, subtle borders

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const errorRed = Color(0xFFC92E2E); // WCAG AA
  static const errorPlaceholder = errorRed; // Backward-compat alias
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

ThemeData buildAppTheme({bool isDark = false}) {
  final Color surfaceColor = isDark
      ? const Color(0xFF141F1A)
      : AppColors.cream100;
  final Color backgroundColor = isDark ? const Color(0xFF000000) : Colors.white;
  final Color textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
  final Color mutedTextColor = isDark
      ? const Color(0xFFA8B5AC)
      : AppColors.ink500;
  final Color primaryBrand = isDark
      ? const Color(0xFF3E8E5E)
      : AppColors.forest700;
  final Color appBarColor = isDark
      ? const Color(0xFF000000)
      : AppColors.forest900;
  final Color borderCol = isDark
      ? const Color(0x22FFFFFF)
      : const Color(0xFFE5DDD0);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryBrand,
    brightness: isDark ? Brightness.dark : Brightness.light,
    primary: primaryBrand,
    secondary: AppColors.gold500,
    error: AppColors.errorRed,
    surface: surfaceColor,
  );

  const serifFontFamily = 'Georgia';
  const serifFallback = ['Liberation Serif', 'serif'];
  const sansFontFamily = 'Calibri';
  const sansFallback = ['Liberation Sans', 'sans-serif'];

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: appBarColor,
      foregroundColor: isDark ? const Color(0xFFFBF4E4) : Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: serifFontFamily,
        fontFamilyFallback: serifFallback,
        fontSize: AppFontSizes.subtitle,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFFFBF4E4) : Colors.white,
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontFamily: serifFontFamily,
        fontFamilyFallback: serifFallback,
        fontSize: AppFontSizes.body,
        color: textColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontFamily: serifFontFamily,
        fontFamilyFallback: serifFallback,
        fontSize: AppFontSizes.body,
        color: textColor,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontFamily: serifFontFamily,
        fontFamilyFallback: serifFallback,
        fontSize: AppFontSizes.title,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: serifFontFamily,
        fontFamilyFallback: serifFallback,
        fontSize: AppFontSizes.subtitle,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(
        fontFamily: sansFontFamily,
        fontFamilyFallback: sansFallback,
        fontSize: AppFontSizes.body,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontFamily: sansFontFamily,
        fontFamilyFallback: sansFallback,
        fontSize: AppFontSizes.small,
        color: mutedTextColor,
      ),
      bodySmall: TextStyle(
        fontFamily: sansFontFamily,
        fontFamilyFallback: sansFallback,
        fontSize: AppFontSizes.caption,
        color: mutedTextColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBrand,
        foregroundColor: isDark ? const Color(0xFF0E1A14) : Colors.white,
        minimumSize: const Size.fromHeight(kMinTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: sansFontFamily,
          fontFamilyFallback: sansFallback,
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        borderSide: BorderSide(color: borderCol),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        borderSide: BorderSide(color: borderCol),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        borderSide: BorderSide(color: primaryBrand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
      ),
      labelStyle: TextStyle(
        fontFamily: sansFontFamily,
        fontFamilyFallback: sansFallback,
        color: mutedTextColor,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: sansFontFamily,
        fontFamilyFallback: sansFallback,
        color: primaryBrand,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

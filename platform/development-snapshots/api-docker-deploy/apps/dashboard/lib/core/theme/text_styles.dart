import 'package:flutter/widgets.dart';

import 'colors.dart';

/// Type tokens from apps/CLAUDE.md.
///
/// Font families: Georgia (fallback Liberation Serif) for headings and body;
/// Calibri (fallback Liberation Sans) for labels, buttons, tables, numeric
/// data. Scale: 12, 14, 16, 20, 26, 34 — nothing between these values.
class AppTextStyles {
  AppTextStyles._();

  static const _serif = 'Georgia';
  static const _serifFallback = ['Liberation Serif'];
  static const _sans = 'Calibri';
  static const _sansFallback = ['Liberation Sans'];

  static const programmeName = TextStyle(
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.cream100,
  );

  static const mastheadMeta = TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: _sansFallback,
    fontSize: 14,
    color: AppColors.cream100,
  );

  static const sectionHeading = TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: _sansFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.ink500,
    letterSpacing: 1.2,
  );

  static const metricValue = TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: _sansFallback,
    fontSize: 34,
    fontWeight: FontWeight.w600,
    color: AppColors.ink900,
  );

  static const metricLabel = TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: _sansFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.ink500,
    letterSpacing: 1.2,
  );

  static const sampleDataChip = TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: _sansFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.gold500,
    letterSpacing: 1.0,
  );

  static const bodyText = TextStyle(
    fontFamily: _serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 16,
    color: AppColors.ink900,
  );

  static const tableText = TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: _sansFallback,
    fontSize: 12,
    color: AppColors.ink900,
  );
}

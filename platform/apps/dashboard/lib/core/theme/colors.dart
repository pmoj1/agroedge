import 'package:flutter/widgets.dart';

/// Design tokens — Savanna Premium palette.
/// Do not add a colour here without updating apps/CLAUDE.md first.
class AppColors {
  AppColors._();

  // ── Core brand ────────────────────────────────────────────────────────────
  static const forest900 =
      Color(0xFF0F3020); // Deep pine — masthead, dark panels
  static const forest700 = Color(0xFF164E33); // Primary brand, CTAs, success
  static const forest500 = Color(0xFF2A7D52); // Interactive hover / mid accent
  static const gold600 = Color(0xFFA67C2E); // Deep ochre — emphasis borders
  static const gold500 = Color(0xFFBD943A); // Ochre — warnings, badges
  static const gold200 = Color(0xFFF5E6C0); // Warm highlight fill

  // ── Data-vis secondaries ──────────────────────────────────────────────────
  static const clay400 =
      Color(0xFFC4896A); // Terracotta — African warmth / expense
  static const sky400 = Color(0xFF4A9BB8); // Map water / chart secondary

  // ── Neutral scale ─────────────────────────────────────────────────────────
  static const cream100 = Color(0xFFF7F2E6); // Silk cream light surface
  static const ink900 = Color(0xFF1A1C1A); // Body text
  static const ink500 = Color(0xFF5F6660); // Secondary / label text
  static const ink200 = Color(0xFFD4D8D5); // Dividers, subtle borders

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const errorRed = Color(0xFFC92E2E); // Anomaly highlighting (WCAG AA)
}

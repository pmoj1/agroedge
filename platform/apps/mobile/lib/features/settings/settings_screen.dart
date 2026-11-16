import 'package:flutter/material.dart';
import '../../core/services/locale_service.dart';
import '../../core/theme.dart';

/// Language settings screen — lets farmer pick their preferred UI language.
/// Instantly rebuilds the entire app in the selected language.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final current = LocaleService.instance.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF000000) : AppColors.cream100;
    final cardBg = isDark ? const Color(0xFF141F1A) : Colors.white;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
    final mutedTextColor = isDark ? const Color(0xFFA8B5AC) : AppColors.ink500;
    final primaryColor = isDark ? const Color(0xFF3E8E5E) : AppColors.forest700;
    final forest100Color = isDark
        ? const Color(0xFF1E3A27)
        : AppColors.forest100;
    final forest900Color = isDark
        ? const Color(0xFF3E8E5E)
        : AppColors.forest900;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('Settings / Mipangilio'),
        backgroundColor: isDark ? const Color(0xFF000000) : AppColors.forest900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Language Section
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: forest100Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Language',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Lugha ya Programu / Mutauro weApp',
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...LocaleService.supportedLocales.map((lang) {
                  final isSelected =
                      current.languageCode == lang.locale.languageCode;
                  return InkWell(
                    onTap: () => LocaleService.instance.setLocale(lang.locale),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? forest100Color.withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.translate_rounded,
                            size: 20,
                            color: primaryColor,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              lang.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected ? forest900Color : textColor,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: primaryColor,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // App info
          Center(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.forest700, AppColors.forest500],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.grass_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'AgroEdge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: forest900Color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Powered by Google Gemini AI',
                  style: TextStyle(fontSize: 12, color: mutedTextColor),
                ),
                const SizedBox(height: 2),
                Text(
                  'v1.0.0 — Pilot Build',
                  style: TextStyle(fontSize: 11, color: mutedTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

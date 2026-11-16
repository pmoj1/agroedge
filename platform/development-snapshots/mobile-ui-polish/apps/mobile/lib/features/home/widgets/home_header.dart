import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';

/// Derives a display name from a farmer's account email, e.g.
/// "j.mokgosi@example.com" -> "J Mokgosi". There is no dedicated farmer
/// display-name field in the data model yet -- see FarmProfile.
String displayNameFromEmail(String? email) {
  if (email == null || email.isEmpty) return '';
  final localPart = email.split('@').first;
  final words = localPart.split(RegExp(r'[._+-]')).where((w) => w.isNotEmpty);
  return words.map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

/// Full-bleed brand-gradient header: greeting with the farmer's name,
/// the farm name, today's date, and sign-out. Replaces the flat AppBar
/// so the Home screen reads as the primary, branded surface it is.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greetingName,
    required this.farmName,
    required this.today,
    required this.onSignOut,
  });

  final String greetingName;
  final String? farmName;
  final String today;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest700, AppColors.forest900],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.sm, AppSpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: kMinTouchTarget,
                height: kMinTouchTarget,
                decoration: const BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle),
                child: const Icon(Icons.eco, color: AppColors.forest900, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeGreeting(greetingName),
                      style: const TextStyle(fontSize: AppFontSizes.title, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (farmName != null && farmName!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        farmName!,
                        style: const TextStyle(fontSize: AppFontSizes.body, fontWeight: FontWeight.w500, color: AppColors.cream100),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      today,
                      style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.cream100),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.commonSignOut,
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: onSignOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// A titled card container used for every content section below the
/// stats row and quick actions -- gives the feed, chart, and AI panels a
/// consistent elevated surface instead of sitting directly on the
/// scaffold background.
class HomeSectionCard extends StatelessWidget {
  const HomeSectionCard({super.key, required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: AppFontSizes.subtitle, fontWeight: FontWeight.w600, color: AppColors.ink900),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle!, style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500)),
            ],
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

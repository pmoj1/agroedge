import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// Programme identity, season selector, and sample-data disclosure.
///
/// The season selector is a filter, not decoration — every number on the
/// screen is scoped to the selected season, because the season is the
/// billing period (programme-overview.md). Step 1 renders it statically;
/// it does not yet filter anything.
class Masthead extends StatelessWidget {
  const Masthead({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.forest900,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Temo Letlotlo', style: AppTextStyles.programmeName),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Ministry of Lands & Agriculture · 2026/27',
                  style: AppTextStyles.mastheadMeta,
                ),
              ],
            ),
          ),
          const _SeasonSelector(),
          const SizedBox(width: AppSpacing.xl),
          const _SampleDataChip(),
        ],
      ),
    );
  }
}

class _SeasonSelector extends StatelessWidget {
  const _SeasonSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cream100.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('2026/27 Season', style: AppTextStyles.mastheadMeta),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.expand_more,
            color: AppColors.cream100,
            size: AppSpacing.lg,
          ),
        ],
      ),
    );
  }
}

/// Present whenever any component on the screen is mock-fed; absent
/// otherwise (programme-overview.md). Step 1 has no data source yet, so it
/// is shown statically pending step 2's mock module.
class _SampleDataChip extends StatelessWidget {
  const _SampleDataChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gold500),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: const Text('SAMPLE DATA', style: AppTextStyles.sampleDataChip),
    );
  }
}

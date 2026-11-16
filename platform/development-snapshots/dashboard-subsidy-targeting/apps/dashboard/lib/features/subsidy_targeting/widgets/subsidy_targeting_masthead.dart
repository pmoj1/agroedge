import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// Programme identity and sample-data disclosure for this screen. The
/// season selector lives in FilterBar here, not the masthead, because on
/// this screen season is one of three functioning filters rather than the
/// sole one -- see programme-overview.md's masthead for the precedent this
/// mirrors visually.
class SubsidyTargetingMasthead extends StatelessWidget {
  const SubsidyTargetingMasthead({super.key, required this.isSampleData});

  final bool isSampleData;

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Temo Letlotlo · Subsidy Targeting',
                    style: AppTextStyles.programmeName),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Ministry of Lands & Agriculture',
                  style: AppTextStyles.mastheadMeta,
                ),
              ],
            ),
          ),
          if (isSampleData) const _SampleDataChip(),
        ],
      ),
    );
  }
}

/// Present whenever the screen's data comes from the local sample module
/// rather than services/api; absent otherwise. Mirrors
/// programme_overview/widgets/masthead.dart's chip exactly.
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

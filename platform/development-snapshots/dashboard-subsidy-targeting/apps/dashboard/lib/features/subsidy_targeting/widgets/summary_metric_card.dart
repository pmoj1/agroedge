import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// A single summary metric tile -- same visual spec as
/// programme_overview/widgets/metric_card.dart (cream background, 34pt
/// Calibri value, uppercase 12pt label), kept as a local copy so this
/// feature folder has no cross-feature dependency.
class SummaryMetricCard extends StatelessWidget {
  const SummaryMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.isEmphasised = false,
  });

  final String label;
  final String value;

  /// Reserved for the gap count/percentage when the gap is above zero.
  /// Colour is always paired with the label word ("Gap"), never used alone
  /// to carry meaning (apps/CLAUDE.md).
  final bool isEmphasised;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cream100,
        border: Border.all(
          color: isEmphasised ? AppColors.gold500 : const Color(0x00000000),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.metricValue.copyWith(
              color: isEmphasised ? AppColors.gold500 : AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label.toUpperCase(), style: AppTextStyles.metricLabel),
        ],
      ),
    );
  }
}

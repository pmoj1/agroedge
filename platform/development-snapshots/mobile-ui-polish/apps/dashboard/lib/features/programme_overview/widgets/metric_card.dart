import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// A single metric tile. [isEmphasised] borders the card gold and colours
/// the value gold — reserved for the unverified count when it is above
/// zero. When zero it is quiet: ink-500, no emphasis (programme-overview.md,
/// Metric row).
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.isEmphasised = false,
  });

  final String label;
  final String value;
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

import 'package:flutter/widgets.dart';

import '../../../core/theme/spacing.dart';
import 'summary_metric_card.dart';

/// Total qualified, total received, gap count, gap percentage -- computed
/// by the screen from the currently filtered district rows so the summary
/// always matches whatever district/season/gap-status filter is applied.
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.qualified,
    required this.received,
    required this.gap,
    required this.gapPercentage,
  });

  final int qualified;
  final int received;
  final int gap;
  final double gapPercentage;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SummaryMetricCard(label: 'Qualified', value: '$qualified'),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: SummaryMetricCard(label: 'Received', value: '$received'),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: SummaryMetricCard(
              label: 'Gap',
              value: '$gap',
              isEmphasised: gap > 0,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: SummaryMetricCard(
              label: 'Gap %',
              value: '${gapPercentage.toStringAsFixed(1)}%',
              isEmphasised: gap > 0,
            ),
          ),
        ],
      ),
    );
  }
}

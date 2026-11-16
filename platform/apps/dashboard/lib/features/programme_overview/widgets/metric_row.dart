import 'package:flutter/widgets.dart';

import '../../../core/theme/spacing.dart';
import 'metric_card.dart';

/// KPI strip — four animated metric cards, hardcoded to the N=3 pilot.
/// Sparklines show weekly progression; deltas show recent change.
class MetricRow extends StatelessWidget {
  const MetricRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MetricCard(
              label: 'Enrolled',
              value: '3',
              delta: '+1 this month',
              sparkline: [1, 1, 2, 3],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: MetricCard(
              label: 'Verified',
              value: '3',
              delta: '+2 this week',
              sparkline: [0, 1, 2, 3],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: MetricCard(
              label: 'Unverified',
              value: '0',
              isEmphasised: false,
              delta: '−1 resolved',
              sparkline: [1, 1, 1, 0],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: MetricCard(
              label: 'Hectares Under Plan',
              value: '4.2',
              delta: '+1.2 ha added',
              sparkline: [1.5, 2.0, 3.0, 4.2],
            ),
          ),
        ],
      ),
    );
  }
}

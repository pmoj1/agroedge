import 'package:flutter/widgets.dart';

import '../../../core/theme/spacing.dart';
import 'metric_card.dart';

/// Hardcoded to the N=3 pilot state described in programme-overview.md.
/// Wiring to services/api lands in a later build step, not here.
class MetricRow extends StatelessWidget {
  const MetricRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: MetricCard(label: 'Enrolled', value: '3')),
          SizedBox(width: AppSpacing.xs),
          Expanded(child: MetricCard(label: 'Verified', value: '3')),
          SizedBox(width: AppSpacing.xs),
          Expanded(child: MetricCard(label: 'Unverified', value: '0')),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: MetricCard(label: 'Hectares Under Plan', value: '4.2'),
          ),
        ],
      ),
    );
  }
}

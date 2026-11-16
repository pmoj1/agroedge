import 'package:flutter/widgets.dart';

import '../../core/theme/spacing.dart';
import 'widgets/distribution_list.dart';
import 'widgets/enrolment_timeline_chart.dart';
import 'widgets/masthead.dart';
import 'widgets/metric_row.dart';
import 'widgets/needs_attention_panel.dart';

/// Programme officer control tower. Static layout, hardcoded to the N=3
/// pilot state per apps/dashboard/docs/programme-overview.md build step 1:
/// no state, no mock module, no data wiring.
///
/// Desktop first, 1440px; responsive down to 1024. Below 1024 this screen
/// is not attempted (programme-overview.md, "Layout").
class ProgrammeOverviewScreen extends StatelessWidget {
  const ProgrammeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440, minWidth: 1024),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Masthead(),
                SizedBox(height: AppSpacing.xl),
                MetricRow(),
                SizedBox(height: AppSpacing.xl),
                _TwoColumnSection(),
                SizedBox(height: AppSpacing.xl),
                EnrolmentTimelineChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TwoColumnSection extends StatelessWidget {
  const _TwoColumnSection();

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: DistributionList()),
          SizedBox(width: AppSpacing.xl),
          Expanded(child: NeedsAttentionPanel()),
        ],
      ),
    );
  }
}

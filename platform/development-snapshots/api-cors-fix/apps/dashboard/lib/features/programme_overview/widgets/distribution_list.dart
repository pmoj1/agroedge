import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'panel_card.dart';

/// District enrolment counts as a two-column list. Below the 25-enrolment
/// threshold this is the only distribution view (programme-overview.md,
/// "The N=3 problem"). The chart state at 25+ enrolments is a later build
/// step and is not implemented here.
class DistributionList extends StatelessWidget {
  const DistributionList({super.key});

  static const _rows = [
    _DistrictCount(district: 'Mahalapye', count: 2),
    _DistrictCount(district: 'Serowe', count: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Distribution',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final row in _rows) _DistrictRow(row: row)],
      ),
    );
  }
}

class _DistrictCount {
  const _DistrictCount({required this.district, required this.count});

  final String district;
  final int count;
}

class _DistrictRow extends StatelessWidget {
  const _DistrictRow({required this.row});

  final _DistrictCount row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(row.district, style: AppTextStyles.tableText)),
          Text(
            '${row.count}',
            style: AppTextStyles.tableText.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

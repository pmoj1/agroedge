import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../models/subsidy_targeting_models.dart';
import 'section_card.dart';

/// Individual qualified-but-not-received farmers, with enough context to
/// act. This is the one place on the screen an individual identity is
/// shown -- an intentional drill-down exception, not a default aggregate
/// view (apps/dashboard/CLAUDE.md; build brief).
class QualifiedNotReceivedTable extends StatelessWidget {
  const QualifiedNotReceivedTable({super.key, required this.rows});

  final List<QualifiedNotReceivedRecord> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SectionCard(
        title: 'Qualified but not received',
        child: Text(
          'No qualified-but-not-received farmers match the current filters.',
          style: AppTextStyles.bodyText,
        ),
      );
    }

    return SectionCard(
      title: 'Qualified but not received',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Individual records -- shown here only to support direct '
            'follow-up action on this specific gap.',
            style: AppTextStyles.tableText,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
            headingRowColor: const WidgetStatePropertyAll(Color(0x00000000)),
            dataRowColor: const WidgetStatePropertyAll(Color(0x00000000)),
            headingTextStyle: AppTextStyles.metricLabel,
            dataTextStyle: AppTextStyles.tableText,
            columns: const [
              DataColumn(label: Text('Farmer')),
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('District')),
              DataColumn(label: Text('Qualified for')),
              DataColumn(label: Text('Reason')),
            ],
            rows: [
              for (final row in rows)
                DataRow(
                  cells: [
                    DataCell(Text(row.farmerName)),
                    DataCell(Text(row.enrolmentId)),
                    DataCell(Text(row.district.name)),
                    DataCell(Text(row.qualifiedFor)),
                    DataCell(
                      Text(
                        row.reason ?? 'Reason not yet recorded',
                        style: row.reason == null
                            ? AppTextStyles.tableText
                                .copyWith(color: AppColors.ink500)
                            : AppTextStyles.tableText,
                      ),
                    ),
                  ],
                ),
            ],
            ),
          ),
        ],
      ),
    );
  }
}

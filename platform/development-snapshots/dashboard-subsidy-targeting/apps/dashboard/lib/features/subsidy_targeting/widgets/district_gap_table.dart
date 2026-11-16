import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../models/subsidy_targeting_models.dart';
import 'section_card.dart';

/// Gap breakdown by district. Defaults to worst-gap-first, since that is
/// what a Ministry officer acts on first (build brief); every column
/// remains sortable via Material's DataTable column-header taps.
class DistrictGapTable extends StatefulWidget {
  const DistrictGapTable({super.key, required this.rows});

  final List<DistrictGap> rows;

  @override
  State<DistrictGapTable> createState() => _DistrictGapTableState();
}

enum _Column { district, qualified, received, gap, gapPercentage }

class _DistrictGapTableState extends State<DistrictGapTable> {
  _Column _sortColumn = _Column.gap;
  bool _ascending = false;

  List<DistrictGap> get _sortedRows {
    final rows = [...widget.rows];
    rows.sort((a, b) {
      switch (_sortColumn) {
        case _Column.district:
          return a.district.name.compareTo(b.district.name);
        case _Column.qualified:
          return a.qualified.compareTo(b.qualified);
        case _Column.received:
          return a.received.compareTo(b.received);
        case _Column.gap:
          return a.gap.compareTo(b.gap);
        case _Column.gapPercentage:
          return a.gapPercentage.compareTo(b.gapPercentage);
      }
    });
    return _ascending ? rows : rows.reversed.toList();
  }

  void _onSort(_Column column) {
    setState(() {
      if (_sortColumn == column) {
        _ascending = !_ascending;
      } else {
        _sortColumn = column;
        _ascending = column == _Column.district;
      }
    });
  }

  int get _sortColumnIndex => _Column.values.indexOf(_sortColumn);

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return const SectionCard(
        title: 'Gap by district',
        child: Text(
          'No districts match the current filters.',
          style: AppTextStyles.bodyText,
        ),
      );
    }

    return SectionCard(
      title: 'Gap by district',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _ascending,
        headingRowColor: const WidgetStatePropertyAll(Color(0x00000000)),
        dataRowColor: const WidgetStatePropertyAll(Color(0x00000000)),
        headingTextStyle: AppTextStyles.metricLabel,
        dataTextStyle: AppTextStyles.tableText,
        columns: [
          DataColumn(
            label: const Text('District'),
            onSort: (_, __) => _onSort(_Column.district),
          ),
          DataColumn(
            label: const Text('Qualified'),
            numeric: true,
            onSort: (_, __) => _onSort(_Column.qualified),
          ),
          DataColumn(
            label: const Text('Received'),
            numeric: true,
            onSort: (_, __) => _onSort(_Column.received),
          ),
          DataColumn(
            label: const Text('Gap'),
            numeric: true,
            onSort: (_, __) => _onSort(_Column.gap),
          ),
          DataColumn(
            label: const Text('Gap %'),
            numeric: true,
            onSort: (_, __) => _onSort(_Column.gapPercentage),
          ),
        ],
        rows: [
          for (final row in _sortedRows)
            DataRow(
              cells: [
                DataCell(Text(row.district.name)),
                DataCell(_TabularNumber('${row.qualified}')),
                DataCell(_TabularNumber('${row.received}')),
                DataCell(
                  _TabularNumber(
                    '${row.gap}',
                    isEmphasised: row.gap > 0,
                  ),
                ),
                DataCell(
                  _TabularNumber(
                    '${row.gapPercentage.toStringAsFixed(1)}%',
                    isEmphasised: row.gap > 0,
                  ),
                ),
              ],
            ),
        ],
        ),
      ),
    );
  }
}

class _TabularNumber extends StatelessWidget {
  const _TabularNumber(this.value, {this.isEmphasised = false});

  final String value;
  final bool isEmphasised;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: AppTextStyles.tableText.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        color: isEmphasised ? AppColors.gold500 : AppColors.ink900,
        fontWeight: isEmphasised ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

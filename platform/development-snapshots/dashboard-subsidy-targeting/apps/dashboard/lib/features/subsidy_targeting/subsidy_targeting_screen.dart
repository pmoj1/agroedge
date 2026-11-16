import 'package:flutter/material.dart';

import '../../core/theme/spacing.dart';
import 'data/subsidy_targeting_sample_data.dart';
import 'models/subsidy_targeting_models.dart';
import 'services/csv_downloader.dart';
import 'services/csv_encoder.dart';
import 'widgets/district_gap_table.dart';
import 'widgets/filter_bar.dart';
import 'widgets/provenance_line.dart';
import 'widgets/qualified_not_received_table.dart';
import 'widgets/subsidy_targeting_masthead.dart';
import 'widgets/summary_row.dart';

/// Who qualifies for a subsidy this season, who actually received it, and
/// where the gap is (apps/dashboard/CLAUDE.md, core view #3).
///
/// Reads from the local sample dataset in data/subsidy_targeting_sample_data.dart
/// -- the institutional schema (institutions, programmes, seasons,
/// enrolments, districts) is still an open proposal, not yet in db/. When
/// services/api exposes a real endpoint, only that data source and this
/// State class's filtering logic change; the widgets below stay the same.
class SubsidyTargetingScreen extends StatefulWidget {
  const SubsidyTargetingScreen({super.key});

  @override
  State<SubsidyTargetingScreen> createState() =>
      _SubsidyTargetingScreenState();
}

class _SubsidyTargetingScreenState extends State<SubsidyTargetingScreen> {
  late String _selectedSeasonId = subsidyTargetingSeasons.first.season.id;
  String? _selectedDistrictId;
  GapStatusFilter _selectedGapStatus = GapStatusFilter.all;

  SubsidyTargetingSeasonData get _seasonData => subsidyTargetingSeasons
      .firstWhere((data) => data.season.id == _selectedSeasonId);

  bool _districtMatchesFilters(DistrictGap district) {
    if (_selectedDistrictId != null &&
        district.district.id != _selectedDistrictId) {
      return false;
    }
    switch (_selectedGapStatus) {
      case GapStatusFilter.all:
        return true;
      case GapStatusFilter.gapOnly:
        return district.gap > 0;
      case GapStatusFilter.fullyReceived:
        return district.gap == 0;
    }
  }

  List<DistrictGap> get _filteredDistricts =>
      _seasonData.byDistrict.where(_districtMatchesFilters).toList();

  /// The qualified-but-not-received list is inherently gap records, so a
  /// "fully received" gap-status filter is honestly represented as an
  /// empty list here rather than ignored.
  List<QualifiedNotReceivedRecord> get _filteredFarmerRecords {
    if (_selectedGapStatus == GapStatusFilter.fullyReceived) return [];
    return _seasonData.qualifiedNotReceived
        .where((record) =>
            _selectedDistrictId == null ||
            record.district.id == _selectedDistrictId)
        .toList();
  }

  int get _summaryQualified =>
      _filteredDistricts.fold(0, (sum, d) => sum + d.qualified);
  int get _summaryReceived =>
      _filteredDistricts.fold(0, (sum, d) => sum + d.received);
  int get _summaryGap => _summaryQualified - _summaryReceived;
  double get _summaryGapPercentage =>
      _summaryQualified == 0 ? 0 : (_summaryGap / _summaryQualified) * 100;

  void _exportCsv() {
    final csv = encodeCsv(
      const ['District', 'Qualified', 'Received', 'Gap', 'Gap %'],
      [
        for (final row in _filteredDistricts)
          [
            row.district.name,
            '${row.qualified}',
            '${row.received}',
            '${row.gap}',
            row.gapPercentage.toStringAsFixed(1),
          ],
      ],
    );
    downloadCsv(
      'subsidy-targeting-${_seasonData.season.id}.csv',
      csv,
    );
  }

  @override
  Widget build(BuildContext context) {
    final seasonData = _seasonData;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440, minWidth: 1024),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SubsidyTargetingMasthead(
                  isSampleData: seasonData.isSampleData,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilterBar(
                  seasons: subsidyTargetingSeasons
                      .map((data) => data.season)
                      .toList(),
                  selectedSeasonId: _selectedSeasonId,
                  onSeasonChanged: (id) => setState(() {
                    _selectedSeasonId = id;
                  }),
                  districts: seasonData.byDistrict
                      .map((district) => district.district)
                      .toList(),
                  selectedDistrictId: _selectedDistrictId,
                  onDistrictChanged: (id) => setState(() {
                    _selectedDistrictId = id;
                  }),
                  selectedGapStatus: _selectedGapStatus,
                  onGapStatusChanged: (status) => setState(() {
                    _selectedGapStatus = status;
                  }),
                  onExportCsv: _exportCsv,
                ),
                const SizedBox(height: AppSpacing.sm),
                ProvenanceLine(
                  seasonName: seasonData.season.name,
                  asOfDate: seasonData.asOfDate,
                  isSampleData: seasonData.isSampleData,
                ),
                const SizedBox(height: AppSpacing.xl),
                SummaryRow(
                  qualified: _summaryQualified,
                  received: _summaryReceived,
                  gap: _summaryGap,
                  gapPercentage: _summaryGapPercentage,
                ),
                const SizedBox(height: AppSpacing.xl),
                DistrictGapTable(rows: _filteredDistricts),
                const SizedBox(height: AppSpacing.xl),
                QualifiedNotReceivedTable(rows: _filteredFarmerRecords),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

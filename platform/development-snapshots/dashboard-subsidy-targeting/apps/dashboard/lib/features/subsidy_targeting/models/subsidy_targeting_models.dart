import 'package:flutter/foundation.dart';

/// Shapes below mirror the institutional schema proposal (institutions,
/// programmes, seasons, enrolments, districts) so that swapping the sample
/// dataset in `data/subsidy_targeting_sample_data.dart` for a
/// `services/api` response is a data-source change, not a rebuild. These
/// are local to this feature folder because the schema is not yet agreed
/// in `packages/shared` -- same situation as the Programme Overview screen.

@immutable
class SubsidySeason {
  const SubsidySeason({required this.id, required this.name});

  final String id;
  final String name;
}

@immutable
class SubsidyDistrict {
  const SubsidyDistrict({required this.id, required this.name});

  final String id;
  final String name;
}

/// Filter values for the "gap status" filter -- distinct from [DistrictGap],
/// which is the underlying data a filter is applied to.
enum GapStatusFilter { all, gapOnly, fullyReceived }

@immutable
class DistrictGap {
  const DistrictGap({
    required this.district,
    required this.qualified,
    required this.received,
  });

  final SubsidyDistrict district;
  final int qualified;
  final int received;

  int get gap => qualified - received;

  double get gapPercentage => qualified == 0 ? 0 : (gap / qualified) * 100;
}

/// An individual qualified-but-not-received record. Farmer identity is
/// intentionally present here -- apps/dashboard/CLAUDE.md and this screen's
/// build brief both carve out an explicit exception for this drill-down,
/// unlike every aggregate view on the dashboard.
@immutable
class QualifiedNotReceivedRecord {
  const QualifiedNotReceivedRecord({
    required this.enrolmentId,
    required this.farmerName,
    required this.district,
    required this.qualifiedFor,
    this.reason,
  });

  final String enrolmentId;
  final String farmerName;
  final SubsidyDistrict district;
  final String qualifiedFor;

  /// Null when the reason a farmer hasn't received their input has not
  /// been recorded -- rendered as an honest "not yet recorded" state
  /// rather than a guessed reason.
  final String? reason;
}

@immutable
class SubsidyTargetingSeasonData {
  const SubsidyTargetingSeasonData({
    required this.season,
    required this.asOfDate,
    required this.byDistrict,
    required this.qualifiedNotReceived,
    required this.isSampleData,
  });

  final SubsidySeason season;

  /// Provenance date for every figure derived from this dataset --
  /// apps/dashboard/CLAUDE.md requires every figure be defensible with a
  /// source, date and method.
  final DateTime asOfDate;
  final List<DistrictGap> byDistrict;
  final List<QualifiedNotReceivedRecord> qualifiedNotReceived;
  final bool isSampleData;

  int get totalQualified =>
      byDistrict.fold(0, (sum, district) => sum + district.qualified);

  int get totalReceived =>
      byDistrict.fold(0, (sum, district) => sum + district.received);

  int get totalGap => totalQualified - totalReceived;

  double get gapPercentage =>
      totalQualified == 0 ? 0 : (totalGap / totalQualified) * 100;
}

import 'package:agroedge_dashboard/features/subsidy_targeting/models/subsidy_targeting_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mahalapye = SubsidyDistrict(id: 'mahalapye', name: 'Mahalapye');
  const serowe = SubsidyDistrict(id: 'serowe', name: 'Serowe');

  group('DistrictGap', () {
    test('computes gap as qualified minus received', () {
      const district =
          DistrictGap(district: mahalapye, qualified: 210, received: 178);

      expect(district.gap, 32);
    });

    test('computes gap percentage relative to qualified', () {
      const district =
          DistrictGap(district: mahalapye, qualified: 200, received: 150);

      expect(district.gapPercentage, 25.0);
    });

    test('reports zero gap percentage when nobody qualified', () {
      const district =
          DistrictGap(district: mahalapye, qualified: 0, received: 0);

      expect(district.gapPercentage, 0);
    });
  });

  group('SubsidyTargetingSeasonData', () {
    test('aggregates totals across all districts', () {
      final data = SubsidyTargetingSeasonData(
        season: const SubsidySeason(id: '2026-27', name: '2026/27'),
        asOfDate: DateTime(2026, 7, 8),
        isSampleData: true,
        byDistrict: const [
          DistrictGap(district: mahalapye, qualified: 210, received: 178),
          DistrictGap(district: serowe, qualified: 165, received: 140),
        ],
        qualifiedNotReceived: const [],
      );

      expect(data.totalQualified, 375);
      expect(data.totalReceived, 318);
      expect(data.totalGap, 57);
      expect(data.gapPercentage, closeTo(15.2, 0.1));
    });

    test('reports zero totals for an empty district list', () {
      final data = SubsidyTargetingSeasonData(
        season: const SubsidySeason(id: '2026-27', name: '2026/27'),
        asOfDate: DateTime(2026, 7, 8),
        isSampleData: true,
        byDistrict: const [],
        qualifiedNotReceived: const [],
      );

      expect(data.totalQualified, 0);
      expect(data.totalGap, 0);
      expect(data.gapPercentage, 0);
    });
  });
}

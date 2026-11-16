import '../models/subsidy_targeting_models.dart';

/// Single mock module for this screen -- same rule as
/// programme-overview.md: one file, not mocks scattered across components.
/// When `services/api` exposes a subsidy-targeting endpoint, this file is
/// what gets deleted; nothing else in the feature folder should need to
/// change shape.
///
/// Districts are real Central District sub-districts around Temo Letlotlo's
/// Mahalapye/Serowe pilot area, consistent with the sample data already used
/// by the Programme Overview screen. Farmer names below are fictional.

const _districts = <SubsidyDistrict>[
  SubsidyDistrict(id: 'mahalapye', name: 'Mahalapye'),
  SubsidyDistrict(id: 'serowe', name: 'Serowe'),
  SubsidyDistrict(id: 'palapye', name: 'Palapye'),
  SubsidyDistrict(id: 'bobonong', name: 'Bobonong'),
  SubsidyDistrict(id: 'tonota', name: 'Tonota'),
  SubsidyDistrict(id: 'shoshong', name: 'Shoshong'),
];

SubsidyDistrict _district(String id) =>
    _districts.firstWhere((district) => district.id == id);

final subsidyTargetingSeasons = <SubsidyTargetingSeasonData>[
  SubsidyTargetingSeasonData(
    season: const SubsidySeason(id: '2026-27', name: '2026/27'),
    asOfDate: DateTime(2026, 7, 8),
    isSampleData: true,
    byDistrict: [
      DistrictGap(district: _district('mahalapye'), qualified: 210, received: 178),
      DistrictGap(district: _district('serowe'), qualified: 165, received: 140),
      DistrictGap(district: _district('palapye'), qualified: 98, received: 52),
      DistrictGap(district: _district('bobonong'), qualified: 140, received: 61),
      DistrictGap(district: _district('tonota'), qualified: 120, received: 108),
      DistrictGap(district: _district('shoshong'), qualified: 87, received: 40),
    ],
    qualifiedNotReceived: [
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0143',
        farmerName: 'Kabelo Moatlhodi',
        district: _district('bobonong'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: 'Distribution not yet scheduled',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0189',
        farmerName: 'Tumelo Kgosana',
        district: _district('shoshong'),
        qualifiedFor: 'Fertiliser top-up',
        reason: 'Pending verification',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0201',
        farmerName: 'Boitumelo Seretse',
        district: _district('palapye'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: 'Input stock delayed at depot',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0058',
        farmerName: 'Onalenna Phiri',
        district: _district('bobonong'),
        qualifiedFor: 'Draught power (ploughing) voucher',
        reason: 'Flagged for duplicate ID -- awaiting resolution',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0312',
        farmerName: 'Neo Mokgosi',
        district: _district('shoshong'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: 'Pending verification',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0077',
        farmerName: 'Lesego Tshweneyame',
        district: _district('palapye'),
        qualifiedFor: 'Fertiliser top-up',
        reason: 'Distribution not yet scheduled',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0265',
        farmerName: 'Thato Ntsime',
        district: _district('mahalapye'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: null,
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0118',
        farmerName: 'Katlego Diphofa',
        district: _district('bobonong'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: 'Distribution not yet scheduled',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0094',
        farmerName: 'Mpho Ramotswe',
        district: _district('serowe'),
        qualifiedFor: 'Fertiliser top-up',
        reason: 'Pending verification',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0233',
        farmerName: 'Refilwe Sekgoma',
        district: _district('shoshong'),
        qualifiedFor: 'Draught power (ploughing) voucher',
        reason: 'Input stock delayed at depot',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0021',
        farmerName: 'Karabo Molosiwa',
        district: _district('tonota'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: 'Farmer transferred district in-season',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0287',
        farmerName: 'Amantle Kereng',
        district: _district('palapye'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: 'Pending verification',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0156',
        farmerName: 'Tshepo Baleseng',
        district: _district('bobonong'),
        qualifiedFor: 'Fertiliser top-up',
        reason: 'Distribution not yet scheduled',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2026-0042',
        farmerName: 'Dineo Mmusi',
        district: _district('serowe'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: null,
      ),
    ],
  ),
  SubsidyTargetingSeasonData(
    season: const SubsidySeason(id: '2025-26', name: '2025/26'),
    asOfDate: DateTime(2026, 1, 20),
    isSampleData: true,
    byDistrict: [
      DistrictGap(district: _district('mahalapye'), qualified: 180, received: 165),
      DistrictGap(district: _district('serowe'), qualified: 140, received: 130),
      DistrictGap(district: _district('palapye'), qualified: 80, received: 70),
      DistrictGap(district: _district('bobonong'), qualified: 110, received: 95),
      DistrictGap(district: _district('tonota'), qualified: 95, received: 90),
      DistrictGap(district: _district('shoshong'), qualified: 70, received: 60),
    ],
    qualifiedNotReceived: [
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2025-0091',
        farmerName: 'Gaone Sechele',
        district: _district('bobonong'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: 'Season closed with distribution incomplete',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2025-0114',
        farmerName: 'Bontle Rasesigo',
        district: _district('mahalapye'),
        qualifiedFor: 'Fertiliser top-up',
        reason: 'Season closed with distribution incomplete',
      ),
      QualifiedNotReceivedRecord(
        enrolmentId: 'TL-2025-0037',
        farmerName: 'Ontiretse Keeme',
        district: _district('palapye'),
        qualifiedFor: 'Seed + fertiliser pack',
        reason: null,
      ),
    ],
  ),
];

import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// Source/date/method line a programme officer can point to when defending
/// these figures to a minister or donor (apps/dashboard/CLAUDE.md, "Users
/// you are building for").
class ProvenanceLine extends StatelessWidget {
  const ProvenanceLine({
    super.key,
    required this.seasonName,
    required this.asOfDate,
    required this.isSampleData,
  });

  final String seasonName;
  final DateTime asOfDate;
  final bool isSampleData;

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${asOfDate.year}-${asOfDate.month.toString().padLeft(2, '0')}-'
        '${asOfDate.day.toString().padLeft(2, '0')}';
    final source = isSampleData ? 'sample dataset' : 'services/api';
    return Text(
      'Season $seasonName · as of $formattedDate · source: $source',
      style: AppTextStyles.tableText.copyWith(color: AppColors.ink500),
    );
  }
}

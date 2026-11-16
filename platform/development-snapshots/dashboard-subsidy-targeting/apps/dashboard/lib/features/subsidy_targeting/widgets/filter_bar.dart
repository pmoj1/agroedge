import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../models/subsidy_targeting_models.dart';

/// Season, district and gap-status filters, plus the CSV export action.
/// Every number on the screen is scoped to these three selections -- there
/// is no unfiltered view, matching apps/CLAUDE.md's "every dashboard query
/// is scoped" rule even though this screen queries a sample dataset rather
/// than services/api.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.seasons,
    required this.selectedSeasonId,
    required this.onSeasonChanged,
    required this.districts,
    required this.selectedDistrictId,
    required this.onDistrictChanged,
    required this.selectedGapStatus,
    required this.onGapStatusChanged,
    required this.onExportCsv,
  });

  final List<SubsidySeason> seasons;
  final String selectedSeasonId;
  final ValueChanged<String> onSeasonChanged;

  final List<SubsidyDistrict> districts;
  final String? selectedDistrictId;
  final ValueChanged<String?> onDistrictChanged;

  final GapStatusFilter selectedGapStatus;
  final ValueChanged<GapStatusFilter> onGapStatusChanged;

  final VoidCallback onExportCsv;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterDropdown<String>(
          label: 'Season',
          value: selectedSeasonId,
          items: [
            for (final season in seasons)
              DropdownMenuItem(value: season.id, child: Text(season.name)),
          ],
          onChanged: (value) {
            if (value != null) onSeasonChanged(value);
          },
        ),
        const SizedBox(width: AppSpacing.lg),
        _FilterDropdown<String?>(
          label: 'District',
          value: selectedDistrictId,
          items: [
            const DropdownMenuItem(value: null, child: Text('All districts')),
            for (final district in districts)
              DropdownMenuItem(
                value: district.id,
                child: Text(district.name),
              ),
          ],
          onChanged: onDistrictChanged,
        ),
        const SizedBox(width: AppSpacing.lg),
        _FilterDropdown<GapStatusFilter>(
          label: 'Gap status',
          value: selectedGapStatus,
          items: const [
            DropdownMenuItem(
              value: GapStatusFilter.all,
              child: Text('All'),
            ),
            DropdownMenuItem(
              value: GapStatusFilter.gapOnly,
              child: Text('Has a gap'),
            ),
            DropdownMenuItem(
              value: GapStatusFilter.fullyReceived,
              child: Text('Fully received'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onGapStatusChanged(value);
          },
        ),
        const Spacer(),
        _ExportCsvButton(onPressed: onExportCsv),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.metricLabel),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ink500.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              style: AppTextStyles.tableText,
              icon: const Icon(Icons.expand_more, size: AppSpacing.lg),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExportCsvButton extends StatelessWidget {
  const _ExportCsvButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.forest700,
        foregroundColor: AppColors.cream100,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
      ),
      icon: const Icon(Icons.file_download_outlined, size: AppSpacing.lg),
      label: Text(
        'Export CSV',
        style: AppTextStyles.metricLabel.copyWith(color: AppColors.cream100),
      ),
    );
  }
}

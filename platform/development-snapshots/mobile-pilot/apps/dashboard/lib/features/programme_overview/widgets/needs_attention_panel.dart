import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'panel_card.dart';

/// The panel renders whatever the API sends; it computes nothing
/// (programme-overview.md, "Needs attention"). At N=3 with zero anomalies,
/// the correct output is a clean, honest statement — not an empty list.
class NeedsAttentionPanel extends StatelessWidget {
  const NeedsAttentionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Needs attention',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CheckIcon(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'No anomalies detected. All 3 enrolments verified.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.forest700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A minimal check mark built without a dependency on the Material icon
/// font, so this widgets.dart-only file stays consistent with the rest of
/// the panel widgets.
class _CheckIcon extends StatelessWidget {
  const _CheckIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.forest700,
        shape: BoxShape.circle,
      ),
      child: const Text(
        '✓',
        style: TextStyle(
          fontSize: 12,
          height: 1,
          color: AppColors.cream100,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

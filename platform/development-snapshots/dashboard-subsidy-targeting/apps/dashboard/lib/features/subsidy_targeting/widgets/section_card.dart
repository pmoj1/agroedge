import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// Section heading above a bordered cream content area. Mirrors
/// programme_overview/widgets/panel_card.dart's visual language; kept as a
/// local copy rather than a cross-feature import so the two feature folders
/// stay independently editable.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppTextStyles.sectionHeading),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.cream100,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: child,
        ),
      ],
    );
  }
}

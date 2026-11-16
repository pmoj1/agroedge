import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// Shared chrome for the distribution and needs-attention panels: a
/// section heading above a bordered content area.
class PanelCard extends StatelessWidget {
  const PanelCard({super.key, required this.title, required this.child});

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

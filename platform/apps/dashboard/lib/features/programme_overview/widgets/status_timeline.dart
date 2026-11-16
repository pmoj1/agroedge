import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'panel_card.dart';

/// Horizontal programme lifecycle stepper.
/// Shows the current pilot stage with a glowing active indicator.
/// Hardcoded to the N=3 pilot state (Enrolment → Verification → Planning active).
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key});

  static const _stages = [
    _Stage(label: 'Enrolment', status: _StageStatus.done),
    _Stage(label: 'Verification', status: _StageStatus.done),
    _Stage(label: 'Planning', status: _StageStatus.active),
    _Stage(label: 'Input Supply', status: _StageStatus.upcoming),
    _Stage(label: 'Harvest', status: _StageStatus.upcoming),
  ];

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Programme stage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connector line with dots
          SizedBox(
            height: 40,
            child: Row(
              children: [
                for (var i = 0; i < _stages.length; i++) ...[
                  _StageDot(stage: _stages[i]),
                  if (i < _stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: _stages[i].status == _StageStatus.done
                              ? AppColors.forest700
                              : AppColors.ink200,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Labels
          Row(
            children: [
              for (var i = 0; i < _stages.length; i++) ...[
                Expanded(
                  child: Text(
                    _stages[i].label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.tableText.copyWith(
                      color: _stages[i].status == _StageStatus.active
                          ? AppColors.forest700
                          : _stages[i].status == _StageStatus.done
                              ? AppColors.ink500
                              : AppColors.ink200,
                      fontWeight: _stages[i].status == _StageStatus.active
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

enum _StageStatus { done, active, upcoming }

class _Stage {
  const _Stage({required this.label, required this.status});
  final String label;
  final _StageStatus status;
}

class _StageDot extends StatelessWidget {
  const _StageDot({required this.stage});
  final _Stage stage;

  @override
  Widget build(BuildContext context) {
    switch (stage.status) {
      case _StageStatus.done:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.forest700,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '✓',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF7F2E6),
              ),
            ),
          ),
        );

      case _StageStatus.active:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.forest700,
            boxShadow: [
              BoxShadow(
                color: AppColors.forest700.withValues(alpha: 0.45),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '▶',
              style: TextStyle(fontSize: 10, color: Color(0xFFF7F2E6)),
            ),
          ),
        );

      case _StageStatus.upcoming:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF7F2E6),
            border: Border.all(color: AppColors.ink200, width: 1.5),
          ),
        );
    }
  }
}

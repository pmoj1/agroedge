import 'package:agroedge_shared/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';

/// A minimal hand-rolled weekly bar chart of activities logged over the
/// last 4 weeks. No charting package -- just bounded containers with a
/// semantics label per bar, cheap enough for a low-end device.
class HomeActivityChart extends StatelessWidget {
  const HomeActivityChart({super.key, required this.activities});

  final List<Activity> activities;

  static const _weekCount = 4;
  static const _chartHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weekFormat = DateFormat.MMMd();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final buckets = List<int>.filled(_weekCount, 0);
    final weekStarts = List<DateTime>.generate(
      _weekCount,
      (i) => today.subtract(Duration(days: (_weekCount - i) * 7 - 1)),
    );

    for (final activity in activities) {
      final activityDay = DateTime(activity.activityDate.year, activity.activityDate.month, activity.activityDate.day);
      final daysAgo = today.difference(activityDay).inDays;
      if (daysAgo < 0 || daysAgo >= _weekCount * 7) continue;
      final bucketFromEnd = daysAgo ~/ 7;
      buckets[_weekCount - 1 - bucketFromEnd]++;
    }

    final maxCount = buckets.fold<int>(0, (max, count) => count > max ? count : max);

    if (maxCount == 0) {
      return Text(l10n.homeTrendEmpty, style: const TextStyle(color: AppColors.ink500));
    }

    // IntrinsicHeight sizes the Row to its tallest column from real text
    // metrics, instead of a hand-guessed pixel budget that broke under a
    // different theme/text scale (see the widget test for the bug this
    // caught: a fixed height overflowed once real fonts were metriced).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _weekCount; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Semantics(
                label: l10n.homeTrendWeekSemanticLabel(weekFormat.format(weekStarts[i]), buckets[i]),
                child: _Bar(
                  count: buckets[i],
                  maxCount: maxCount,
                  maxHeight: _chartHeight,
                  weekLabel: weekFormat.format(weekStarts[i]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.count, required this.maxCount, required this.maxHeight, required this.weekLabel});

  final int count;
  final int maxCount;
  final double maxHeight;
  final String weekLabel;

  @override
  Widget build(BuildContext context) {
    final rawFraction = count / maxCount;
    final displayFraction = count == 0 ? 0.0 : (rawFraction < 0.06 ? 0.06 : rawFraction);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$count', style: const TextStyle(fontSize: AppFontSizes.small, fontWeight: FontWeight.w600, color: AppColors.ink900)),
        const SizedBox(height: AppSpacing.xs),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: displayFraction),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Container(
              height: maxHeight * value,
              decoration: const BoxDecoration(
                color: AppColors.forest700,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xs)),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(weekLabel, style: const TextStyle(fontSize: AppFontSizes.caption, color: AppColors.ink500)),
      ],
    );
  }
}

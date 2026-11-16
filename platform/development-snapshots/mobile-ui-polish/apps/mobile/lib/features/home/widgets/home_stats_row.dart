import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// The three compact stat cards shown right under the header: activities
/// logged, expenses, and income for the current month. This is the
/// highest-value addition for turning a mostly-empty Home screen into an
/// at-a-glance dashboard.
class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({super.key, required this.stats});

  final List<HomeStat> stats;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight gives the Row a bounded height so
    // CrossAxisAlignment.stretch can equalise the three card heights --
    // required because this Row sits directly inside a ListView, whose
    // unbounded height would otherwise make a plain stretch crash.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatCard(stat: stats[i])),
          ],
        ],
      ),
    );
  }
}

class HomeStat {
  const HomeStat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final HomeStat stat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle),
              child: Icon(stat.icon, color: AppColors.forest900, size: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              stat.value,
              style: const TextStyle(fontSize: AppFontSizes.title, fontWeight: FontWeight.bold, color: AppColors.ink900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              stat.label,
              style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

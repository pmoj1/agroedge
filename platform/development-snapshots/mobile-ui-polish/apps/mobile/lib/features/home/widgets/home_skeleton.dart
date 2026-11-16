import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Loading placeholder for the dashboard content below the header --
/// mirrors the stats row, quick actions grid, and section cards so the
/// page doesn't jump once real data arrives. Wrapped in a ListView so
/// RefreshIndicator still has a scrollable to attach to while loading.
///
/// Deliberately static (no ticker/animation): this state is on screen for
/// well under a second on a warm cache, so a shimmer buys little and only
/// costs battery/CPU on a low-end device.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        Row(
          children: [
            Expanded(child: _SkeletonBox(height: 96)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _SkeletonBox(height: 96)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _SkeletonBox(height: 96)),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _SkeletonBox(height: 104)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _SkeletonBox(height: 104)),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _SkeletonBox(height: 104)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _SkeletonBox(height: 104)),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        _SkeletonBox(height: 180),
        SizedBox(height: AppSpacing.lg),
        _SkeletonBox(height: 140),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.ink500.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
    );
  }
}

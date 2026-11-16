import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'panel_card.dart';

/// Crop analytics panel with animated horizontal progress bars,
/// projected vs actual yield comparison, and commodity price strip.
/// All values are sample/pilot data for Temo Letlotlo 2026/27.
class CropAnalyticsCard extends StatefulWidget {
  const CropAnalyticsCard({super.key});

  @override
  State<CropAnalyticsCard> createState() => _CropAnalyticsCardState();
}

class _CropAnalyticsCardState extends State<CropAnalyticsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  static const _crops = [
    _CropData(
      name: 'Maize',
      crop: 'Zea mays',
      target: 3.2,
      actual: 2.5,
      pct: 0.78,
      color: AppColors.forest700,
      icon: Icons.grass_rounded,
    ),
    _CropData(
      name: 'Sorghum',
      crop: 'Sorghum bicolor',
      target: 2.1,
      actual: 1.4,
      pct: 0.65,
      color: AppColors.gold500,
      icon: Icons.agriculture_rounded,
    ),
    _CropData(
      name: 'Sunflower',
      crop: 'Helianthus annuus',
      target: 1.6,
      actual: 1.4,
      pct: 0.89,
      color: AppColors.clay400,
      icon: Icons.local_florist_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Crop Performance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Season tag
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 12, color: AppColors.ink500),
            const SizedBox(width: 4),
            Text('2026/27 Wet Season — Projection',
                style:
                    AppTextStyles.tableText.copyWith(color: AppColors.ink500)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.forest700.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: AppColors.forest700.withValues(alpha: 0.20)),
              ),
              child: Text('3 Farmers · 4.2 ha',
                  style: AppTextStyles.tableText.copyWith(
                      color: AppColors.forest700, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),

          // Animated crop bars
          AnimatedBuilder(
            animation: _progress,
            builder: (_, __) {
              return Column(
                children: [
                  for (final c in _crops) ...[
                    _CropBarRow(crop: c, progress: _progress.value),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              );
            },
          ),

          // Divider
          Container(height: 1, color: const Color(0xFFE5DDD0)),
          const SizedBox(height: AppSpacing.lg),

          // Yield summary cards
          const Row(children: [
            Expanded(
                child: _YieldSummaryBox(
              label: 'Avg Projected',
              value: '2.30 t/ha',
              delta: '+0.4 vs plan',
              isPositive: true,
            )),
            SizedBox(width: AppSpacing.md),
            Expanded(
                child: _YieldSummaryBox(
              label: 'Avg Actual (to date)',
              value: '1.77 t/ha',
              delta: 'On track',
              isPositive: true,
            )),
            SizedBox(width: AppSpacing.md),
            Expanded(
                child: _YieldSummaryBox(
              label: 'Revenue Potential',
              value: 'BWP 5 900',
              delta: 'est. end of season',
              isPositive: null,
            )),
          ]),
          const SizedBox(height: AppSpacing.xl),

          // Commodity price ticker
          _CommodityTicker(),
        ],
      ),
    );
  }
}

class _CropData {
  const _CropData({
    required this.name,
    required this.crop,
    required this.target,
    required this.actual,
    required this.pct,
    required this.color,
    required this.icon,
  });
  final String name;
  final String crop;
  final double target;
  final double actual;
  final double pct;
  final Color color;
  final IconData icon;
}

class _CropBarRow extends StatelessWidget {
  const _CropBarRow({required this.crop, required this.progress});
  final _CropData crop;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: crop.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(crop.icon, size: 14, color: crop.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(crop.name,
                style: AppTextStyles.tableText.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.ink900)),
            Text(crop.crop,
                style: AppTextStyles.tableText.copyWith(
                    fontSize: 10,
                    color: AppColors.ink500,
                    fontStyle: FontStyle.italic)),
          ]),
          const Spacer(),
          Text(
            '${(crop.actual).toStringAsFixed(1)} / ${crop.target.toStringAsFixed(1)} t/ha',
            style: AppTextStyles.tableText.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: crop.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(crop.pct * 100).toInt()}%',
              style: TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: crop.color,
              ),
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Stack(children: [
          // Background track
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: crop.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          // Target marker line at 100%
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 2, color: AppColors.ink200),
          ),
          // Animated fill
          FractionallySizedBox(
            widthFactor: (crop.pct * progress).clamp(0.0, 1.0),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [crop.color.withValues(alpha: 0.6), crop.color],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

class _YieldSummaryBox extends StatelessWidget {
  const _YieldSummaryBox({
    required this.label,
    required this.value,
    required this.delta,
    required this.isPositive,
  });
  final String label;
  final String value;
  final String delta;
  final bool? isPositive;

  @override
  Widget build(BuildContext context) {
    final Color deltaColor = isPositive == null
        ? AppColors.ink500
        : isPositive!
            ? AppColors.forest700
            : AppColors.errorRed;
    final IconData? deltaIcon = isPositive == null
        ? null
        : isPositive!
            ? Icons.trending_up
            : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cream100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5DDD0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppTextStyles.tableText
                .copyWith(fontSize: 10, color: AppColors.ink500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontFamily: 'Calibri',
              fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink900,
            )),
        const SizedBox(height: 3),
        Row(children: [
          if (deltaIcon != null) Icon(deltaIcon, size: 10, color: deltaColor),
          if (deltaIcon != null) const SizedBox(width: 2),
          Flexible(
              child: Text(delta,
                  style: AppTextStyles.tableText
                      .copyWith(fontSize: 10, color: deltaColor))),
        ]),
      ]),
    );
  }
}

/// Scrolling commodity price strip (static mock data).
class _CommodityTicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const prices = [
      _PriceData(
          crop: 'Maize', price: 'BWP 3 200/t', change: '+2.1%', up: true),
      _PriceData(
          crop: 'Sorghum', price: 'BWP 2 750/t', change: '-0.4%', up: false),
      _PriceData(
          crop: 'Sunflower', price: 'BWP 4 100/t', change: '+1.8%', up: true),
      _PriceData(
          crop: 'Groundnuts', price: 'BWP 5 600/t', change: '+0.9%', up: true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.show_chart, size: 12, color: AppColors.ink500),
          const SizedBox(width: 4),
          Text('Commodity Prices (AMIS — Jun 2026)',
              style: AppTextStyles.tableText
                  .copyWith(fontSize: 10, color: AppColors.ink500)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          for (final p in prices) ...[
            Expanded(child: _PriceTile(data: p)),
            if (p != prices.last) const SizedBox(width: AppSpacing.sm),
          ],
        ]),
      ],
    );
  }
}

class _PriceData {
  const _PriceData({
    required this.crop,
    required this.price,
    required this.change,
    required this.up,
  });
  final String crop;
  final String price;
  final String change;
  final bool up;
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({required this.data});
  final _PriceData data;

  @override
  Widget build(BuildContext context) {
    final color = data.up ? AppColors.forest700 : AppColors.errorRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data.crop,
            style: AppTextStyles.tableText.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.ink900)),
        const SizedBox(height: 2),
        Text(data.price,
            style: AppTextStyles.tableText
                .copyWith(fontSize: 10, color: AppColors.ink500)),
        const SizedBox(height: 2),
        Row(children: [
          Icon(data.up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 12, color: color),
          Text(data.change,
              style: AppTextStyles.tableText.copyWith(
                  fontSize: 9, fontWeight: FontWeight.w700, color: color)),
        ]),
      ]),
    );
  }
}

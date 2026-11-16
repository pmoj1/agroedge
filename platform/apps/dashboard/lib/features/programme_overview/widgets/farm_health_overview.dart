import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'panel_card.dart';

/// Farm health overview panel with three animated radial gauges:
/// Soil Health, Moisture Level, and Crop Vigour.
/// All values are sample pilot data — N=3 Temo Letlotlo 2026/27.
class FarmHealthOverview extends StatefulWidget {
  const FarmHealthOverview({super.key});

  @override
  State<FarmHealthOverview> createState() => _FarmHealthOverviewState();
}

class _FarmHealthOverviewState extends State<FarmHealthOverview>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  static const _gauges = [
    _GaugeData(
      label: 'Soil Health',
      score: '82',
      value: 0.82,
      color: AppColors.forest700,
      icon: Icons.eco_rounded,
      unit: '/100',
      trend: '+3 vs last season',
    ),
    _GaugeData(
      label: 'Moisture',
      score: '67',
      value: 0.67,
      color: AppColors.sky400,
      icon: Icons.water_drop_rounded,
      unit: '%',
      trend: 'Adequate',
    ),
    _GaugeData(
      label: 'Crop Vigour',
      score: '91',
      value: 0.91,
      color: AppColors.forest500,
      icon: Icons.grass_rounded,
      unit: '/100',
      trend: 'Excellent',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
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
      title: 'Farm Health Overview',
      child: AnimatedBuilder(
        animation: _progress,
        builder: (_, __) {
          return Column(
            children: [
              // Overall health score banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.forest700.withValues(alpha: 0.08),
                      AppColors.forest500.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.forest700.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(children: [
                  const Icon(Icons.monitor_heart_outlined,
                      size: 16, color: AppColors.forest700),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Overall Programme Health',
                      style: AppTextStyles.tableText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.forest900,
                      )),
                  const Spacer(),
                  Text(
                    '${(80 * _progress.value).toInt()}/100',
                    style: const TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forest700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.forest700.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('GOOD',
                        style: TextStyle(
                          fontFamily: 'Calibri',
                          fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forest700,
                          letterSpacing: 0.5,
                        )),
                  ),
                ]),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Radial gauges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final g in _gauges)
                    _RadialGauge(
                      data: g,
                      progress: _progress.value,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Activity indicators
              const _ActivityBar(
                label: 'Fertilizer applied',
                progress: 1.0,
                color: AppColors.forest700,
                value: '3/3 farms',
              ),
              const SizedBox(height: AppSpacing.sm),
              const _ActivityBar(
                label: 'Site visits completed',
                progress: 0.67,
                color: AppColors.gold500,
                value: '2/3 farms',
              ),
              const SizedBox(height: AppSpacing.sm),
              const _ActivityBar(
                label: 'Soil tests submitted',
                progress: 0.33,
                color: AppColors.clay400,
                value: '1/3 farms',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GaugeData {
  const _GaugeData({
    required this.label,
    required this.score,
    required this.value,
    required this.color,
    required this.icon,
    required this.unit,
    required this.trend,
  });
  final String label;
  final String score;
  final double value;
  final Color color;
  final IconData icon;
  final String unit;
  final String trend;
}

class _RadialGauge extends StatelessWidget {
  const _RadialGauge({required this.data, required this.progress});
  final _GaugeData data;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: _RadialGaugePainter(
              value: data.value,
              color: data.color,
              progress: progress,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(data.icon, size: 14, color: data.color),
                  const SizedBox(height: 2),
                  Text(
                    '${(double.parse(data.score) * progress).toInt()}${data.unit}',
                    style: TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: const [
                        'Liberation Sans',
                        'sans-serif'
                      ],
                      fontSize: data.unit == '/100' ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: data.color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          data.label,
          style: AppTextStyles.tableText.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(data.trend,
              style: TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: data.color,
              )),
        ),
      ],
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  const _RadialGaugePainter({
    required this.value,
    required this.color,
    required this.progress,
  });

  final double value;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 8;

    // Arc angles: start at bottom-left (-210°), sweep 240°
    const startAngle = (150 * math.pi) / 180;
    const totalSweep = (240 * math.pi) / 180;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      totalSweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Filled progress arc
    final sweepAngle = totalSweep * value * progress;
    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: startAngle,
            endAngle: startAngle + totalSweep,
            colors: [
              color.withValues(alpha: 0.5),
              color,
            ],
          ).createShader(
              Rect.fromCircle(center: Offset(cx, cy), radius: radius))
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter old) =>
      old.progress != progress;
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({
    required this.label,
    required this.progress,
    required this.color,
    required this.value,
  });
  final String label;
  final double progress;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 140,
        child: Text(label,
            style: AppTextStyles.tableText.copyWith(color: AppColors.ink500)),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      SizedBox(
        width: 52,
        child: Text(value,
            textAlign: TextAlign.right,
            style: AppTextStyles.tableText.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            )),
      ),
    ]);
  }
}

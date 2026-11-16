import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'panel_card.dart';

/// Animated step chart showing cumulative enrolment over time.
/// The step path draws itself on mount (600ms, easeInOut) with a gradient fill.
/// Hardcoded to the N=3 pilot per programme-overview.md build step 1.
///
/// Design choice: step chart (not smooth curve) because a smoothed curve through
/// three points would misstate the shape of the data.
class EnrolmentTimelineChart extends StatefulWidget {
  const EnrolmentTimelineChart({super.key});

  @override
  State<EnrolmentTimelineChart> createState() => _EnrolmentTimelineChartState();
}

class _EnrolmentTimelineChartState extends State<EnrolmentTimelineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  static const _points = [
    _TimelinePoint(label: '12 Sep', cumulativeEnrolled: 1),
    _TimelinePoint(label: '19 Sep', cumulativeEnrolled: 2),
    _TimelinePoint(label: '03 Oct', cumulativeEnrolled: 3),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Enrolment over time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (_, __) => CustomPaint(
                painter: _AnimatedStepChartPainter(
                  points: _points,
                  progress: _progress.value,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Date labels aligned to chart x positions
          Row(
            children: [
              for (var i = 0; i < _points.length; i++) ...[
                if (i > 0) const Spacer(),
                Text(_points[i].label, style: AppTextStyles.tableText),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Legend
          Row(children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.forest700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Text('Cumulative enrolments', style: AppTextStyles.tableText),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.forest700.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '3 total',
                style: AppTextStyles.tableText.copyWith(
                  color: AppColors.forest700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _TimelinePoint {
  const _TimelinePoint({required this.label, required this.cumulativeEnrolled});
  final String label;
  final int cumulativeEnrolled;
}

class _AnimatedStepChartPainter extends CustomPainter {
  const _AnimatedStepChartPainter({
    required this.points,
    required this.progress,
  });

  final List<_TimelinePoint> points;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxValue = points.map((p) => p.cumulativeEnrolled).reduce(math.max);
    final lastIndex = points.length - 1;
    const vPad = 20.0; // top padding so the line doesn't clip

    double xFor(int i) => size.width * i / lastIndex;
    double yFor(int i) {
      final frac = points[i].cumulativeEnrolled / maxValue;
      return size.height - vPad - frac * (size.height - vPad * 2);
    }

    // --- Build animated step path ---
    final totalLength =
        lastIndex.toDouble(); // segments: each unit = 1 step segment pair
    final drawn = progress * totalLength;

    final path = Path()..moveTo(xFor(0), yFor(0));

    for (var i = 0; i < lastIndex; i++) {
      final segStart = i.toDouble();
      final segEnd = i + 1.0;

      if (drawn <= segStart) break;

      final x0 = xFor(i);
      final x1 = xFor(i + 1);
      final y0 = yFor(i);
      final y1 = yFor(i + 1);

      if (drawn >= segEnd) {
        // Fully drawn: horizontal then vertical
        path.lineTo(x1, y0);
        path.lineTo(x1, y1);
      } else {
        // Partially drawing horizontal segment
        final t = drawn - segStart;
        final midX = x0 + (x1 - x0) * t;
        path.lineTo(midX, y0);
      }
    }

    // Gradient fill below path
    final fillPath = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(path.getBounds().right, size.height)
      ..lineTo(xFor(0), size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.forest700.withValues(alpha: 0.18),
            AppColors.forest700.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Step line
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.forest700
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Data point dots
    for (var i = 0; i < points.length; i++) {
      if (i.toDouble() > drawn) break;
      canvas.drawCircle(
        Offset(xFor(i), yFor(i)),
        4.5,
        Paint()..color = AppColors.forest700,
      );
      canvas.drawCircle(
        Offset(xFor(i), yFor(i)),
        2.5,
        Paint()..color = Colors.white,
      );
    }

    // Y-axis gridlines (subtle)
    final gridPaint = Paint()
      ..color = const Color(0xFFE5DDD0)
      ..strokeWidth = 0.8;
    for (var step = 1; step <= maxValue; step++) {
      final y =
          size.height - vPad - (step / maxValue) * (size.height - vPad * 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      // Y-axis label
      const textStyle = TextStyle(
        fontFamily: 'Calibri',
        fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
        fontSize: 10,
        color: AppColors.ink500,
        fontFeatures: [FontFeature.tabularFigures()],
      );
      final tp = TextPainter(
        text: TextSpan(text: '$step', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedStepChartPainter old) =>
      old.progress != progress;
}

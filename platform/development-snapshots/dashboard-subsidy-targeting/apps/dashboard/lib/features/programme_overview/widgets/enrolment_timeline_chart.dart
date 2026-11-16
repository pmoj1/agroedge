import 'package:flutter/widgets.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'panel_card.dart';

/// Three enrolment dates rendered as three steps. A smoothed curve through
/// three points would misstate the shape of the data (programme-overview.md,
/// "Enrolment over time"). Hardcoded to the N=3 pilot state; step 1 only,
/// no data wiring yet.
class EnrolmentTimelineChart extends StatelessWidget {
  const EnrolmentTimelineChart({super.key});

  static const _points = [
    _TimelinePoint(label: '12 Sep', cumulativeEnrolled: 1),
    _TimelinePoint(label: '19 Sep', cumulativeEnrolled: 2),
    _TimelinePoint(label: '03 Oct', cumulativeEnrolled: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Enrolment over time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: CustomPaint(painter: _StepChartPainter(points: _points)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final point in _points)
                Text(point.label, style: AppTextStyles.tableText),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelinePoint {
  const _TimelinePoint({
    required this.label,
    required this.cumulativeEnrolled,
  });

  final String label;
  final int cumulativeEnrolled;
}

class _StepChartPainter extends CustomPainter {
  const _StepChartPainter({required this.points});

  final List<_TimelinePoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxValue = points
        .map((point) => point.cumulativeEnrolled)
        .reduce((a, b) => a > b ? a : b);
    final stepX = size.width / points.length;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x0 = stepX * i;
      final x1 = stepX * (i + 1);
      final y = size.height -
          (points[i].cumulativeEnrolled / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x0, size.height);
        path.lineTo(x0, y);
      } else {
        path.lineTo(x0, y);
      }
      path.lineTo(x1, y);
    }

    final linePaint = Paint()
      ..color = AppColors.forest700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _StepChartPainter oldDelegate) => false;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// Animated metric card with count-up value, micro-sparkline, and optional
/// delta badge. Replaces the original static MetricCard.
///
/// [isEmphasised] adds gold border + forest500 value colour (for Unverified > 0).
/// All N=3 pilot data values are passed in as [value]; animation tweens 0→value.
class MetricCard extends StatefulWidget {
  const MetricCard({
    required this.label,
    required this.value,
    this.isEmphasised = false,
    this.delta,
    this.sparkline,
    this.suffix = '',
    super.key,
  });

  final String label;
  final String value;
  final bool isEmphasised;

  /// Optional delta string e.g. '+1 this week'. Shown in a small badge.
  final String? delta;

  /// 3-point sparkline history values (oldest → newest).
  final List<double>? sparkline;
  final String suffix;

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _countAnim;

  double get _numericValue => double.tryParse(widget.value) ?? 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _countAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFloat = widget.value.contains('.');
    final Color valueColor =
        widget.isEmphasised ? AppColors.forest500 : AppColors.ink900;
    final Color borderColor =
        widget.isEmphasised ? AppColors.gold500 : const Color(0xFFE5DDD0);
    final double borderWidth = widget.isEmphasised ? 2.0 : 1.0;

    return AnimatedBuilder(
      animation: _countAnim,
      builder: (context, _) {
        final displayValue = _numericValue * _countAnim.value;
        final formatted = isFloat
            ? displayValue.toStringAsFixed(1)
            : displayValue.toInt().toString();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: widget.isEmphasised
                ? AppColors.gold200.withValues(alpha: 0.25)
                : AppColors.cream100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: AppColors.forest900.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Value + delta row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '$formatted${widget.suffix}',
                      style:
                          AppTextStyles.metricValue.copyWith(color: valueColor),
                    ),
                  ),
                  if (widget.delta != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.forest700.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        widget.delta!,
                        style: const TextStyle(
                          fontFamily: 'Calibri',
                          fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.label.toUpperCase(),
                style: AppTextStyles.metricLabel,
              ),
              // Sparkline
              if (widget.sparkline != null &&
                  widget.sparkline!.length >= 2) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 28,
                  child: CustomPaint(
                    size: const Size(double.infinity, 28),
                    painter: _SparklinePainter(
                      points: widget.sparkline!,
                      progress: _countAnim.value,
                      color: widget.isEmphasised
                          ? AppColors.gold500
                          : AppColors.forest700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.points,
    required this.progress,
    required this.color,
  });

  final List<double> points;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final maxVal = points.reduce(math.max);
    if (maxVal == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final step = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = step * i;
      final y = size.height - (points[i] / maxVal) * size.height * progress;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Gradient fill below sparkline
    final fillPath = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.20), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(path, paint);

    // End dot
    final lastX = size.width;
    final lastY = size.height - (points.last / maxVal) * size.height * progress;
    canvas.drawCircle(
      Offset(lastX, lastY),
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.progress != progress;
}

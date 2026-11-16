import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. ANIMATED LINE / STEP CHART
// ─────────────────────────────────────────────────────────────────────────────

class AppLineChartData {
  const AppLineChartData({required this.label, required this.value});
  final String label;
  final double value;
}

class AppLineChart extends StatefulWidget {
  const AppLineChart({
    required this.data,
    this.height = 140.0,
    this.isStep = false,
    this.color = AppColors.forest700,
    super.key,
  });

  final List<AppLineChartData> data;
  final double height;
  final bool isStep;
  final Color color;

  @override
  State<AppLineChart> createState() => _AppLineChartState();
}

class _AppLineChartState extends State<AppLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _animation = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _LineChartPainter(
                  data: widget.data,
                  progress: _animation.value,
                  isStep: widget.isStep,
                  color: widget.color,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.data
              .map(
                (d) => Text(
                  d.label,
                  style: const TextStyle(
                    fontFamily: 'Calibri',
                    fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                    fontSize: 10,
                    color: AppColors.ink500,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.data,
    required this.progress,
    required this.isStep,
    required this.color,
  });

  final List<AppLineChartData> data;
  final double progress;
  final bool isStep;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxVal = data.map((d) => d.value).reduce(math.max);
    final minVal = data.map((d) => d.value).reduce(math.min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = stepX * i;
      final y =
          size.height -
          ((data[i].value - minVal) / range) * size.height * progress;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        if (isStep) {
          path.lineTo(
            x,
            size.height -
                ((data[i - 1].value - minVal) / range) * size.height * progress,
          );
          path.lineTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }

    final fillPath = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.12), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(path, linePaint);

    if (data.isNotEmpty) {
      final lastX = size.width;
      final lastY =
          size.height -
          ((data.last.value - minVal) / range) * size.height * progress;
      canvas.drawCircle(Offset(lastX, lastY), 3.5, Paint()..color = color);
      canvas.drawCircle(
        Offset(lastX, lastY),
        1.5,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.progress != progress || old.isStep != isStep || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. ANIMATED DOUBLE BAR CHART
// ─────────────────────────────────────────────────────────────────────────────

class AppBarChartData {
  const AppBarChartData({
    required this.label,
    required this.valueA,
    required this.valueB,
  });
  final String label;
  final double valueA;
  final double valueB;
}

class AppDoubleBarChart extends StatefulWidget {
  const AppDoubleBarChart({
    required this.data,
    this.height = 130.0,
    this.colorA = AppColors.forest700,
    this.colorB = AppColors.clay400,
    this.labelA = 'A',
    this.labelB = 'B',
    super.key,
  });

  final List<AppBarChartData> data;
  final double height;
  final Color colorA;
  final Color colorB;
  final String labelA;
  final String labelB;

  @override
  State<AppDoubleBarChart> createState() => _AppDoubleBarChartState();
}

class _AppDoubleBarChartState extends State<AppDoubleBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _animation = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _DoubleBarChartPainter(
                  data: widget.data,
                  progress: _animation.value,
                  colorA: widget.colorA,
                  colorB: widget.colorB,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.data
              .map(
                (d) => Text(
                  d.label,
                  style: const TextStyle(
                    fontFamily: 'Calibri',
                    fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                    fontSize: 10,
                    color: AppColors.ink500,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: widget.colorA, label: widget.labelA),
            const SizedBox(width: AppSpacing.lg),
            _LegendItem(color: widget.colorB, label: widget.labelB),
          ],
        ),
      ],
    );
  }
}

class _DoubleBarChartPainter extends CustomPainter {
  const _DoubleBarChartPainter({
    required this.data,
    required this.progress,
    required this.colorA,
    required this.colorB,
  });

  final List<AppBarChartData> data;
  final double progress;
  final Color colorA;
  final Color colorB;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data
        .map((d) => math.max(d.valueA, d.valueB))
        .reduce(math.max);
    if (maxVal == 0) return;

    final n = data.length;
    final groupWidth = size.width / n;
    const gap = 3.0;
    final barWidth = (groupWidth - gap * 3.0) / 2.0;
    const radius = Radius.circular(3.0);

    final paintA = Paint()
      ..color = colorA
      ..style = PaintingStyle.fill;
    final paintB = Paint()
      ..color = colorB
      ..style = PaintingStyle.fill;

    for (var i = 0; i < n; i++) {
      final startX = groupWidth * i + gap;
      final hA = (data[i].valueA / maxVal) * size.height * progress;
      final hB = (data[i].valueB / maxVal) * size.height * progress;

      if (hA > 0) {
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            startX,
            size.height - hA,
            startX + barWidth,
            size.height,
            topLeft: radius,
            topRight: radius,
          ),
          paintA,
        );
      }

      if (hB > 0) {
        final startXB = startX + barWidth + gap;
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            startXB,
            size.height - hB,
            startXB + barWidth,
            size.height,
            topLeft: radius,
            topRight: radius,
          ),
          paintB,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DoubleBarChartPainter old) =>
      old.progress != progress || old.colorA != colorA || old.colorB != colorB;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Calibri',
            fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
            fontSize: 11,
            color: AppColors.ink900,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. RADIAL PROGRESS GAUGE
// ─────────────────────────────────────────────────────────────────────────────

class AppRadialGauge extends StatefulWidget {
  const AppRadialGauge({
    required this.value,
    required this.label,
    this.max = 100.0,
    this.size = 90.0,
    this.color = AppColors.forest700,
    super.key,
  });

  final double value;
  final String label;
  final double max;
  final double size;
  final Color color;

  @override
  State<AppRadialGauge> createState() => _AppRadialGaugeState();
}

class _AppRadialGaugeState extends State<AppRadialGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _animation = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadialGaugePainter(
                  value: widget.value,
                  max: widget.max,
                  progress: _animation.value,
                  color: widget.color,
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 6.0),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: widget.value),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, val, child) {
                  return Text(
                    val.toInt().toString(),
                    style: TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: const [
                        'Liberation Sans',
                        'sans-serif',
                      ],
                      fontSize: widget.size * 0.24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink900,
                    ),
                  );
                },
              ),
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                  fontSize: widget.size * 0.09,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  const _RadialGaugePainter({
    required this.value,
    required this.max,
    required this.progress,
    required this.color,
  });

  final double value;
  final double max;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = (size.width - 10.0) / 2.0;
    const startAngle = 3.0 * math.pi / 4.0;
    const totalAngle = 3.0 * math.pi / 2.0;

    final trackPaint = Paint()
      ..color = AppColors.ink200.withValues(alpha: 0.4)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle,
      false,
      trackPaint,
    );

    final sweepAngle = (value / max) * totalAngle * progress;
    final valuePaint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter old) =>
      old.progress != progress || old.value != value || old.color != color;
}

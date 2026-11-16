import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'panel_card.dart';

/// Stylised Botswana choropleth map coloured by enrolment density.
/// Animated pin drops for enrolled districts.
/// Hardcoded to N=3 pilot: Mahalapye (2), Serowe (1), all others empty.
class ChoroplethMap extends StatefulWidget {
  const ChoroplethMap({super.key});

  @override
  State<ChoroplethMap> createState() => _ChoroplethMapState();
}

class _ChoroplethMapState extends State<ChoroplethMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _pinCtrl;
  late Animation<double> _pinAnim;

  // Districts with enrolment counts
  static const _districts = [
    _District(name: 'Mahalapye', count: 2, relX: 0.58, relY: 0.52),
    _District(name: 'Serowe', count: 1, relX: 0.60, relY: 0.42),
  ];

  @override
  void initState() {
    super.initState();
    _pinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pinAnim = CurvedAnimation(parent: _pinCtrl, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _pinCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Geographic distribution',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              const h = 220.0;
              return SizedBox(
                height: h,
                child: Stack(
                  children: [
                    // Map canvas
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomPaint(
                          painter: _BotswanaMapPainter(),
                        ),
                      ),
                    ),
                    // Animated pins
                    AnimatedBuilder(
                      animation: _pinAnim,
                      builder: (_, __) {
                        return Stack(
                          children: [
                            for (final d in _districts)
                              _MapPin(
                                district: d,
                                canvasWidth: w,
                                canvasHeight: h,
                                scale: _pinAnim.value,
                              ),
                          ],
                        );
                      },
                    ),
                    // Map label
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BOTSWANA — Temo Letlotlo Pilot Zones',
                          style: TextStyle(
                            fontFamily: 'Calibri',
                            fontFamilyFallback: [
                              'Liberation Sans',
                              'sans-serif'
                            ],
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // Colour legend
          const Row(
            children: [
              _LegendItem(color: AppColors.forest700, label: '2 enrolments'),
              SizedBox(width: AppSpacing.lg),
              _LegendItem(color: AppColors.forest500, label: '1 enrolment'),
              SizedBox(width: AppSpacing.lg),
              _LegendItem(color: Color(0xFFE8F2EC), label: 'No enrolments'),
            ],
          ),
        ],
      ),
    );
  }
}

class _District {
  const _District({
    required this.name,
    required this.count,
    required this.relX,
    required this.relY,
  });
  final String name;
  final int count;
  final double relX; // 0–1 relative position on canvas
  final double relY;
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.district,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.scale,
  });

  final _District district;
  final double canvasWidth;
  final double canvasHeight;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final x = district.relX * canvasWidth;
    final y = district.relY * canvasHeight;
    final color =
        district.count >= 2 ? AppColors.forest700 : AppColors.forest500;
    const pinH = 32.0;

    return Positioned(
      left: x - 10,
      top: y - pinH * scale,
      child: Transform.scale(
        scale: scale.clamp(0.0, 1.0),
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bubble label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${district.count}  ${district.name}',
                style: const TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            // Pin tail
            Container(width: 2, height: 8, color: color),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFFE5DDD0)),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: AppTextStyles.tableText),
    ]);
  }
}

/// CustomPainter drawing a stylised, schematic Botswana outline.
/// The shape is approximated as a near-square with a notch for
/// the Caprivi-adjacent border — accuracy is intentionally cartographic-schematic,
/// not survey-grade. The map uses relative coordinates so it scales with canvas size.
class _BotswanaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rand = math.Random(7); // seeded for determinism

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFD4E8DC),
    );

    // Okavango Delta (sky-tinted water feature)
    final deltaPath = Path()
      ..moveTo(w * 0.18, h * 0.22)
      ..quadraticBezierTo(w * 0.22, h * 0.15, w * 0.30, h * 0.18)
      ..quadraticBezierTo(w * 0.26, h * 0.28, w * 0.18, h * 0.22);
    canvas.drawPath(
      deltaPath,
      Paint()..color = AppColors.sky400.withValues(alpha: 0.50),
    );

    // Makgadikgadi Pan (cream/salt flats)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.55, h * 0.32),
          width: w * 0.18,
          height: h * 0.10),
      Paint()..color = AppColors.cream100.withValues(alpha: 0.80),
    );

    // Kalahari desert texture (subtle dots)
    final desertPaint = Paint()..color = const Color(0xFFB8D4C0);
    for (var i = 0; i < 30; i++) {
      final cx = rand.nextDouble() * w;
      final cy = rand.nextDouble() * h;
      canvas.drawCircle(Offset(cx, cy), 1 + rand.nextDouble() * 2, desertPaint);
    }

    // District fills — approximated rectangles/polygons for the enrolled districts
    // Mahalapye district (central)
    _drawDistrict(
        canvas,
        [
          Offset(w * 0.50, h * 0.42),
          Offset(w * 0.68, h * 0.42),
          Offset(w * 0.68, h * 0.62),
          Offset(w * 0.50, h * 0.62),
        ],
        AppColors.forest700.withValues(alpha: 0.30));

    // Serowe district (central-north)
    _drawDistrict(
        canvas,
        [
          Offset(w * 0.50, h * 0.28),
          Offset(w * 0.68, h * 0.28),
          Offset(w * 0.68, h * 0.42),
          Offset(w * 0.50, h * 0.42),
        ],
        AppColors.forest500.withValues(alpha: 0.22));

    // Botswana border outline (schematic — approximate rectangular country shape)
    final borderPath = Path()
      ..moveTo(w * 0.12, h * 0.08) // NW corner
      ..lineTo(w * 0.52, h * 0.06) // N edge
      ..lineTo(w * 0.58, h * 0.10) // NE notch
      ..lineTo(w * 0.88, h * 0.12) // NE
      ..lineTo(w * 0.90, h * 0.88) // SE
      ..lineTo(w * 0.58, h * 0.92) // S
      ..lineTo(w * 0.32, h * 0.88) // SW
      ..lineTo(w * 0.12, h * 0.92) // W-South
      ..lineTo(w * 0.10, h * 0.35) // W mid
      ..lineTo(w * 0.12, h * 0.08) // back to NW
      ..close();

    canvas.drawPath(
        borderPath,
        Paint()
          ..color = const Color(0xFF8FBA9A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  void _drawDistrict(Canvas canvas, List<Offset> pts, Color color) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

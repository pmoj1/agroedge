import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

/// Premium weather panel with animated rotating sun, count-up temperature,
/// condition overview, and 5-day forecast strip.
/// Pilot data: Mahalapye District, Botswana — Wet Season 2026/27.
/// All values are sample data (no live API at build step 1).
class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _sunCtrl;
  late Animation<double> _sunRotation;
  late Animation<double> _tempAnim;

  static const _forecast = [
    _ForecastDay(
        label: 'MON', temp: 26, icon: Icons.wb_sunny_rounded, isRain: false),
    _ForecastDay(
        label: 'TUE', temp: 28, icon: Icons.wb_sunny_rounded, isRain: false),
    _ForecastDay(
        label: 'WED', temp: 23, icon: Icons.cloud_queue_rounded, isRain: true),
    _ForecastDay(
        label: 'THU',
        temp: 22,
        icon: Icons.thunderstorm_outlined,
        isRain: true),
    _ForecastDay(
        label: 'FRI', temp: 25, icon: Icons.cloud_queue_rounded, isRain: false),
  ];

  @override
  void initState() {
    super.initState();
    _sunCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _sunRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_sunCtrl);
    _tempAnim = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(
          parent: _sunCtrl,
          curve: const Interval(0, 0.12, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _sunCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WEATHER CONDITIONS',
          style: TextStyle(
            fontFamily: 'Calibri',
            fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.ink500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E6B96), Color(0xFF0A4568), Color(0xFF082E44)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E6B96).withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Subtle cloud texture
                Positioned.fill(
                    child: CustomPaint(painter: _CloudTexturePainter())),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location + icon row
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: Color(0xAAFFFFFF)),
                          const SizedBox(width: 4),
                          const Text(
                            'Mahalapye, Botswana',
                            style: TextStyle(
                              fontFamily: 'Calibri',
                              fontFamilyFallback: [
                                'Liberation Sans',
                                'sans-serif'
                              ],
                              fontSize: 12,
                              color: Color(0xAAFFFFFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Animated rotating sun
                          AnimatedBuilder(
                            animation: _sunRotation,
                            builder: (_, __) => Transform.rotate(
                              angle: _sunRotation.value,
                              child: CustomPaint(
                                size: const Size(36, 36),
                                painter: _SunPainter(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Temperature
                      AnimatedBuilder(
                        animation: _tempAnim,
                        builder: (_, __) => Text(
                          '${_tempAnim.value.toInt()}°C',
                          style: const TextStyle(
                            fontFamily: 'Calibri',
                            fontFamilyFallback: [
                              'Liberation Sans',
                              'sans-serif'
                            ],
                            fontSize: 52,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            height: 1.0,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Partly Cloudy · Wet Season',
                        style: TextStyle(
                          fontFamily: 'Calibri',
                          fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                          fontSize: 13,
                          color: Color(0xCCFFFFFF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Conditions row
                      const Row(
                        children: [
                          _ConditionChip(
                              icon: Icons.water_drop_outlined,
                              label: '68%',
                              sub: 'Humidity'),
                          SizedBox(width: AppSpacing.md),
                          _ConditionChip(
                              icon: Icons.air_rounded,
                              label: '14 km/h',
                              sub: 'Wind NE'),
                          SizedBox(width: AppSpacing.md),
                          _ConditionChip(
                              icon: Icons.umbrella_outlined,
                              label: '12 mm',
                              sub: 'This week'),
                          SizedBox(width: AppSpacing.md),
                          _ConditionChip(
                              icon: Icons.wb_twilight_rounded,
                              label: 'UV 6',
                              sub: 'High'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Divider
                      Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.12)),
                      const SizedBox(height: AppSpacing.md),
                      // 5-day forecast
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final d in _forecast) _ForecastTile(day: d),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.icon,
    required this.label,
    required this.sub,
  });
  final IconData icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Calibri',
                        fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ))),
            ]),
            const SizedBox(height: 2),
            Text(sub,
                style: const TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                  fontSize: 10,
                  color: Color(0x88FFFFFF),
                )),
          ],
        ),
      ),
    );
  }
}

class _ForecastTile extends StatelessWidget {
  const _ForecastTile({required this.day});
  final _ForecastDay day;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(day.label,
          style: const TextStyle(
            fontFamily: 'Calibri',
            fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0x88FFFFFF),
          )),
      const SizedBox(height: 4),
      Icon(day.icon,
          size: 18,
          color:
              day.isRain ? const Color(0x88FFFFFF) : const Color(0xFFFFD54F)),
      const SizedBox(height: 4),
      Text('${day.temp}°',
          style: const TextStyle(
            fontFamily: 'Calibri',
            fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          )),
    ]);
  }
}

class _ForecastDay {
  const _ForecastDay({
    required this.label,
    required this.temp,
    required this.icon,
    required this.isRain,
  });
  final String label;
  final int temp;
  final IconData icon;
  final bool isRain;
}

/// CustomPainter for a stylised sun with 8 rays.
class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Core circle
    canvas.drawCircle(
        Offset(cx, cy), 10, Paint()..color = const Color(0xFFFFD54F));

    // Rays
    for (var i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      const innerR = 12.0;
      const outerR = 17.0;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle)),
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _CloudTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    // Subtle cloud blobs
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.2), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 45, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.30), 35, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

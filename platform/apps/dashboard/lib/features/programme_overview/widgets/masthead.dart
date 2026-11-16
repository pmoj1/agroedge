import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// Enhanced programme masthead.
/// Dark forest900 gradient background with diagonal texture overlay.
/// Live clock in top-right. Glassmorphic season selector chip.
/// Breadcrumb navigation: Ministry / Programme / Season.
class Masthead extends StatefulWidget {
  const Masthead({super.key});

  @override
  State<Masthead> createState() => _MastheadState();
}

class _MastheadState extends State<Masthead> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timeString {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.forest900, Color(0xFF0D2B1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Stack(
          children: [
            // Diagonal texture
            Positioned.fill(
                child: CustomPaint(painter: _DiagonalTexturePainter())),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb + clock
                  Row(
                    children: [
                      const _Breadcrumb(
                        crumbs: [
                          'Ministry of Lands & Agriculture',
                          'Temo Letlotlo',
                          '2026/27',
                        ],
                      ),
                      const Spacer(),
                      // Live clock
                      Text(
                        _timeString,
                        style: const TextStyle(
                          fontFamily: 'Calibri',
                          fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0x66FFFFFF),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Main row: programme name + chips
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Programme name
                      const Expanded(
                        child: Text(
                          'Temo Letlotlo',
                          style: AppTextStyles.programmeName,
                        ),
                      ),
                      // Season selector (glassmorphic)
                      const _GlassSeasonSelector(),
                      const SizedBox(width: AppSpacing.md),
                      // Sample data chip
                      const _SampleDataChip(),
                      const SizedBox(width: AppSpacing.md),
                      // Export button (UI only)
                      _ExportButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.crumbs});
  final List<String> crumbs;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < crumbs.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text('›',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0x44FFFFFF),
                  )),
            ),
          Text(
            crumbs[i],
            style: TextStyle(
              fontFamily: 'Calibri',
              fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
              fontSize: 11,
              fontWeight:
                  i == crumbs.length - 1 ? FontWeight.w600 : FontWeight.normal,
              color: i == crumbs.length - 1
                  ? const Color(0xAAFFFFFF)
                  : const Color(0x55FFFFFF),
            ),
          ),
        ],
      ],
    );
  }
}

class _GlassSeasonSelector extends StatelessWidget {
  const _GlassSeasonSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(
          color: AppColors.cream100.withValues(alpha: 0.20),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 13, color: AppColors.cream100),
          SizedBox(width: 5),
          Text('2026/27 Season', style: AppTextStyles.mastheadMeta),
          SizedBox(width: AppSpacing.xs),
          Icon(Icons.expand_more,
              color: AppColors.cream100, size: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SampleDataChip extends StatelessWidget {
  const _SampleDataChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        color: AppColors.gold500.withValues(alpha: 0.08),
      ),
      child: const Text('SAMPLE DATA', style: AppTextStyles.sampleDataChip),
    );
  }
}

class _ExportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.forest500.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(color: AppColors.forest500.withValues(alpha: 0.40)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download_outlined, size: 13, color: AppColors.cream100),
          SizedBox(width: 5),
          Text(
            'Export',
            style: TextStyle(
              fontFamily: 'Calibri',
              fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.cream100,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1.0;
    for (var i = -size.height.toInt(); i < size.width.toInt(); i += 16) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CARD VARIANTS
// ─────────────────────────────────────────────────────────────────────────────

enum AppCardVariant {
  /// Cream background, soft shadow — the standard dashboard surface.
  elevated,

  /// Cream background, fine border — for forms and secondary panels.
  outlined,

  /// Translucent, blurred — for overlays atop dark backgrounds.
  glass,
}

// ─────────────────────────────────────────────────────────────────────────────
// APP CARD
// ─────────────────────────────────────────────────────────────────────────────

/// Reusable base card with three built-in micro-interactions:
///
/// 1. **Entrance** — fade + 8 px slide-up (400 ms, easeOut) triggered on mount,
///    with an optional [entranceDelay] for staggered reveals.
/// 2. **Hover** (desktop) — shadow deepens, background lightens (160 ms).
/// 3. **Tap** — scale pulse to 0.977 (80 ms in, 180 ms out) when [onTap] != null.
class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.borderRadius = 10.0,
    this.onTap,
    this.entranceDelay = Duration.zero,
    this.backgroundColor,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  /// Provide a callback to make the card tappable and enable the tap
  /// scale micro-interaction.
  final VoidCallback? onTap;

  /// Stagger the entrance animation. Pass multiples of 80 ms for rows of cards.
  final Duration entranceDelay;

  /// Override the resolved background colour.
  final Color? backgroundColor;

  /// Override the resolved border colour.
  final Color? borderColor;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  // ── Entrance ──────────────────────────────────────────────────────────────
  late AnimationController _entranceCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // ── Interaction state ─────────────────────────────────────────────────────
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    if (widget.entranceDelay == Duration.zero) {
      _entranceCtrl.forward();
    } else {
      Future.delayed(widget.entranceDelay, () {
        if (mounted) _entranceCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Resolved styles ───────────────────────────────────────────────────────
  Color get _resolvedBackground {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return switch (widget.variant) {
      AppCardVariant.elevated =>
        _isHovered ? const Color(0xFFFFFFFF) : AppColors.cream100,
      AppCardVariant.outlined => AppColors.cream100,
      AppCardVariant.glass => Colors.white.withValues(alpha: 0.09),
    };
  }

  Color get _resolvedBorder {
    if (widget.borderColor != null) return widget.borderColor!;
    return switch (widget.variant) {
      AppCardVariant.elevated => _isHovered
          ? AppColors.forest700.withValues(alpha: 0.18)
          : const Color(0xFFE5DDD0),
      AppCardVariant.outlined => const Color(0xFFE5DDD0),
      AppCardVariant.glass => Colors.white.withValues(alpha: 0.15),
    };
  }

  List<BoxShadow> get _resolvedShadows {
    if (widget.variant == AppCardVariant.glass) return [];
    if (_isHovered && widget.onTap != null) {
      return [
        BoxShadow(
          color: AppColors.forest700.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.forest900.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          cursor: widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: widget.onTap != null
                ? (_) => setState(() => _isPressed = true)
                : null,
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: _isPressed ? 0.977 : 1.0,
              duration: _isPressed
                  ? const Duration(milliseconds: 80)
                  : const Duration(milliseconds: 180),
              curve: _isPressed ? Curves.easeIn : Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                padding: widget.padding ?? const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: _resolvedBackground,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(color: _resolvedBorder),
                  boxShadow: _resolvedShadows,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP STAT CARD
// ─────────────────────────────────────────────────────────────────────────────

/// Pre-composed metric card: animated count-up value, label, optional
/// delta badge, optional sparkline, and the AppCard entrance animation.
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    required this.label,
    required this.value,
    this.icon,
    this.delta,
    this.isPositiveDelta,
    this.sparkline,
    this.suffix = '',
    this.isEmphasised = false,
    this.entranceDelay = Duration.zero,
    this.onTap,
    super.key,
  });

  final String label;

  /// Numeric string. Will be count-up animated if parseable as a number.
  final String value;

  final IconData? icon;

  /// Short change description e.g. '+3 this week'.
  final String? delta;

  /// Controls badge colour: true=forest green, false=error red, null=neutral.
  final bool? isPositiveDelta;

  /// 3-6 historical values for the micro-sparkline.
  final List<double>? sparkline;
  final String suffix;

  /// Adds a subtle gold-tinted border and forest green value colour.
  final bool isEmphasised;

  final Duration entranceDelay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final numericValue = double.tryParse(value) ?? 0;
    final isFloat = value.contains('.');
    final Color valueColor =
        isEmphasised ? AppColors.forest500 : AppColors.ink900;
    final Color borderColor =
        isEmphasised ? AppColors.gold500 : const Color(0xFFE5DDD0);
    final Color? bgColor =
        isEmphasised ? AppColors.gold200.withValues(alpha: 0.22) : null;

    return AppCard(
      entranceDelay: entranceDelay,
      borderColor: borderColor,
      backgroundColor: bgColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + delta
          Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.ink500),
              const SizedBox(width: AppSpacing.xs),
            ],
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.metricLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (delta != null)
              _DeltaBadge(delta: delta!, isPositive: isPositiveDelta),
          ]),
          const SizedBox(height: AppSpacing.sm),

          // Animated count-up value
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: numericValue),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (_, v, __) => Text(
              '${isFloat ? v.toStringAsFixed(1) : v.toInt()}$suffix',
              style: AppTextStyles.metricValue.copyWith(color: valueColor),
            ),
          ),

          // Sparkline
          if (sparkline != null && sparkline!.length >= 2) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 32,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (_, progress, __) => CustomPaint(
                  painter: _SparklinePainter(
                    points: sparkline!,
                    progress: progress,
                    color:
                        isEmphasised ? AppColors.gold500 : AppColors.forest700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.delta, required this.isPositive});
  final String delta;
  final bool? isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive == null
        ? AppColors.ink500
        : isPositive!
            ? AppColors.forest700
            : AppColors.errorRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(delta,
          style: TextStyle(
            fontFamily: 'Calibri',
            fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          )),
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

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final step = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final drawn = (points.length - 1) * progress;
      if (i > drawn) break;
      final x = step * i;
      final y = size.height - (points[i] / maxVal) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    // Gradient fill
    final fillPath = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(size.width * progress, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.18), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.progress != progress;
}

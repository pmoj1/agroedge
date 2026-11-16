import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

enum AppCardVariant { elevated, outlined, glass }

class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.onTap,
    this.entranceDelay = Duration.zero,
    this.backgroundColor,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Duration entranceDelay;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
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

  Color get _resolvedBackground {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (widget.variant) {
      AppCardVariant.elevated =>
        isDark ? const Color(0xFF121413) : AppColors.cream100,
      AppCardVariant.outlined =>
        isDark ? const Color(0xFF121413) : AppColors.cream100,
      AppCardVariant.glass => Colors.white.withValues(alpha: 0.10),
    };
  }

  Color get _resolvedBorder {
    if (widget.borderColor != null) return widget.borderColor!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (widget.variant) {
      AppCardVariant.elevated =>
        isDark ? const Color(0xFF262C28) : const Color(0xFFE5DDD0),
      AppCardVariant.outlined =>
        isDark ? const Color(0xFF262C28) : const Color(0xFFE5DDD0),
      AppCardVariant.glass => Colors.white.withValues(alpha: 0.15),
    };
  }

  List<BoxShadow> get _resolvedShadows {
    if (widget.variant == AppCardVariant.glass) return [];
    return [
      BoxShadow(
        color: AppColors.forest900.withValues(alpha: 0.04),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _resolvedBackground,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: _resolvedBorder),
        boxShadow: _resolvedShadows,
      ),
      child: widget.child,
    );

    if (widget.variant == AppCardVariant.glass) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: cardContent,
        ),
      );
    }

    if (widget.margin != null) {
      cardContent = Container(margin: widget.margin, child: cardContent);
    }

    final hasTap = widget.onTap != null;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: hasTap ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: hasTap ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: hasTap ? () => setState(() => _isPressed = false) : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: _isPressed
                ? const Duration(milliseconds: 60)
                : const Duration(milliseconds: 150),
            curve: _isPressed ? Curves.easeIn : Curves.easeOutBack,
            child: cardContent,
          ),
        ),
      ),
    );
  }
}

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
  final String value;
  final IconData? icon;
  final String? delta;
  final bool? isPositiveDelta;
  final List<double>? sparkline;
  final String suffix;
  final bool isEmphasised;
  final Duration entranceDelay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final numericValue = double.tryParse(value) ?? 0;
    final isFloat = value.contains('.');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color valueColor = isEmphasised
        ? AppColors.forest500
        : (isDark ? const Color(0xFFFBF4E4) : AppColors.ink900);
    final Color borderColor = isEmphasised
        ? AppColors.gold500
        : (isDark ? const Color(0xFF262C28) : const Color(0xFFE5DDD0));
    final Color? bgColor = isEmphasised
        ? AppColors.gold200.withValues(alpha: 0.22)
        : null;

    return AppCard(
      entranceDelay: entranceDelay,
      borderColor: borderColor,
      backgroundColor: bgColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.ink500),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Calibri',
                    fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink500,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (delta != null)
                _DeltaBadge(delta: delta!, isPositive: isPositiveDelta),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: numericValue),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (_, v, child) => Text(
              '${isFloat ? v.toStringAsFixed(1) : v.toInt()}$suffix',
              style: TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                fontSize: 34,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
          if (sparkline != null && sparkline!.length >= 2) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 28,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (_, progress, child) => CustomPaint(
                  painter: _SparklinePainter(
                    points: sparkline!,
                    progress: progress,
                    color: isEmphasised
                        ? AppColors.gold500
                        : AppColors.forest700,
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

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.delta, required this.isPositive});
  final String delta;
  final bool? isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive == null
        ? AppColors.ink500
        : (isPositive! ? AppColors.forest700 : AppColors.errorRed);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        delta,
        style: TextStyle(
          fontFamily: 'Calibri',
          fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
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
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

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

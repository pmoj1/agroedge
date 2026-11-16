import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ORIGINAL COMPONENTS (preserved, shimmer enhanced)
// ─────────────────────────────────────────────────────────────────────────────

/// A premium, customizable card matching the Silk Cream aesthetic.
/// Supports micro-press scale animations when [onTap] is provided.
class AgroCard extends StatefulWidget {
  const AgroCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  State<AgroCard> createState() => _AgroCardState();
}

class _AgroCardState extends State<AgroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.cream100,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: widget.borderColor ?? const Color(0xFFE5DDD0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest900.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(scale: _scaleAnimation, child: card),
      );
    }

    return card;
  }
}

/// Animated pulsing skeleton loader with shimmer gradient.
class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFFE5DDD0),
                  Color(0xFFF0EAE0),
                  Color(0xFFE5DDD0),
                ],
                stops: [0.0, _animation.value, 1.0],
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal shake animation for validation errors.
class AgroValidationErrorShake extends StatefulWidget {
  const AgroValidationErrorShake({
    required this.child,
    required this.shouldShake,
    super.key,
  });

  final Widget child;
  final bool shouldShake;

  @override
  State<AgroValidationErrorShake> createState() =>
      _AgroValidationErrorShakeState();
}

class _AgroValidationErrorShakeState extends State<AgroValidationErrorShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant AgroValidationErrorShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = _controller.value;
        final double offset =
            8.0 *
            (progress < 1.0
                ? (progress * 4 % 2 == 0 ? 1 : -1) * (1 - progress)
                : 0.0);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHASE II — NEW PREMIUM COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

/// Glass morphism card using BackdropFilter blur.
/// Use over gradient or image backgrounds for a frosted-glass effect.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.sigma = 20.0,
    this.tintColor,
    this.borderColor,
    this.borderRadius = 16.0,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double sigma;
  final Color? tintColor;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tintColor ?? Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animated pill badge — icon + label + optional count value.
class AgroStatBadge extends StatefulWidget {
  const AgroStatBadge({
    required this.label,
    this.icon,
    this.value,
    this.color = AppColors.forest700,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData? icon;
  final String? value;
  final Color color;
  final VoidCallback? onTap;

  @override
  State<AgroStatBadge> createState() => _AgroStatBadgeState();
}

class _AgroStatBadgeState extends State<AgroStatBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) _ctrl.forward();
      },
      onTapUp: (_) {
        if (widget.onTap != null) _ctrl.reverse();
      },
      onTapCancel: () {
        if (widget.onTap != null) _ctrl.reverse();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: widget.color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 14, color: widget.color),
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
              if (widget.value != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    widget.value!,
                    style: const TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width gradient CTA button — forest700 → forest500.
/// Includes a shimmer sweep on press and a drop shadow.
class AgroGradientButton extends StatefulWidget {
  const AgroGradientButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<AgroGradientButton> createState() => _AgroGradientButtonState();
}

class _AgroGradientButtonState extends State<AgroGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmer;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shimmer = Tween<double>(
      begin: -1.5,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.isLoading;
    return GestureDetector(
      onTapDown: enabled
          ? (_) {
              setState(() => _pressed = true);
              _shimmerCtrl.forward(from: 0);
            }
          : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [AppColors.forest700, AppColors.forest500],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: enabled ? null : AppColors.ink200,
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.forest700.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _shimmer,
                  builder: (_, _) => Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment(_shimmer.value - 1, 0),
                          end: Alignment(_shimmer.value, 0),
                        ),
                      ),
                    ),
                  ),
                ),
                widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: 'Calibri',
                          fontFamilyFallback: const [
                            'Liberation Sans',
                            'sans-serif',
                          ],
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: enabled ? Colors.white : AppColors.ink500,
                          letterSpacing: 0.2,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated number count-up using TweenAnimationBuilder.
class AnimatedCountUp extends StatelessWidget {
  const AnimatedCountUp({
    required this.end,
    this.start = 0,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 0,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    super.key,
  });

  final double end;
  final double start;
  final String prefix;
  final String suffix;
  final int decimalPlaces;
  final Duration duration;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: start, end: end),
      duration: duration,
      curve: Curves.easeOut,
      builder: (_, value, _) {
        return Text(
          '$prefix${value.toStringAsFixed(decimalPlaces)}$suffix',
          style: style,
        );
      },
    );
  }
}

/// Data record for AnimatedBarChart.
class BarChartData {
  const BarChartData({
    required this.label,
    required this.income,
    required this.expense,
  });
  final String label;
  final double income;
  final double expense;
}

/// Animated dual-bar chart — income (forest700) vs expense (clay400).
/// Bars animate upward from zero on mount.
class AnimatedBarChart extends StatefulWidget {
  const AnimatedBarChart({required this.data, this.height = 120.0, super.key});

  final List<BarChartData> data;
  final double height;

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
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
            animation: _progress,
            builder: (_, _) => CustomPaint(
              painter: _BarChartPainter(
                data: widget.data,
                progress: _progress.value,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final d in widget.data)
              Text(
                d.label,
                style: const TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                  fontSize: 10,
                  color: AppColors.ink500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(color: AppColors.forest700, label: 'Income'),
            const SizedBox(width: 16),
            _Dot(color: AppColors.clay400, label: 'Expense'),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.label});
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Calibri',
            fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
            fontSize: 10,
            color: AppColors.ink500,
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({required this.data, required this.progress});
  final List<BarChartData> data;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.fold<double>(
      0,
      (p, d) => math.max(p, math.max(d.income, d.expense)),
    );
    if (maxVal == 0) return;

    final n = data.length;
    final groupW = size.width / n;
    const gap = 3.0;
    final barW = (groupW - gap * 3) / 2;
    const r = Radius.circular(3);

    final incPaint = Paint()
      ..color = AppColors.forest700
      ..style = PaintingStyle.fill;
    final expPaint = Paint()
      ..color = AppColors.clay400
      ..style = PaintingStyle.fill;

    for (var i = 0; i < n; i++) {
      final gx = groupW * i + gap;
      final ih = (data[i].income / maxVal) * size.height * progress;
      final eh = (data[i].expense / maxVal) * size.height * progress;
      if (ih > 0) {
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            gx,
            size.height - ih,
            gx + barW,
            size.height,
            topLeft: r,
            topRight: r,
          ),
          incPaint,
        );
      }
      if (eh > 0) {
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            gx + barW + gap,
            size.height - eh,
            gx + barW * 2 + gap,
            size.height,
            topLeft: r,
            topRight: r,
          ),
          expPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.progress != progress;
}

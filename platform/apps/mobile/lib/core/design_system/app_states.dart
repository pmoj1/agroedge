import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';
import 'app_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class AppEmptyState extends StatefulWidget {
  const AppEmptyState({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
    this.icon,
    super.key,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData? icon;

  @override
  State<AppEmptyState> createState() => _AppEmptyStateState();
}

class _AppEmptyStateState extends State<AppEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.forest700.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.forest700.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      widget.icon ?? Icons.folder_open_outlined,
                      size: 28,
                      color: AppColors.forest700,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['Liberation Serif', 'serif'],
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                fontSize: 13,
                color: AppColors.ink500,
                height: 1.4,
              ),
            ),
            if (widget.actionLabel != null &&
                widget.onActionPressed != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: widget.actionLabel!,
                onPressed: widget.onActionPressed!,
                variant: AppButtonVariant.filled,
                height: 44.0,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. LOADING STATE / SHIMMER / SPINNER
// ─────────────────────────────────────────────────────────────────────────────

class AppLoadingState extends StatefulWidget {
  const AppLoadingState({
    this.width = double.infinity,
    this.height = 80.0,
    this.borderRadius = 8.0,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<AppLoadingState> createState() => _AppLoadingStateState();
}

class _AppLoadingStateState extends State<AppLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _shimmer = Tween<double>(
      begin: 0.3,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        return Opacity(
          opacity: _shimmer.value,
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
                stops: [0.0, _shimmer.value, 1.0],
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

class AppLoadingSpinner extends StatefulWidget {
  const AppLoadingSpinner({
    this.size = 36.0,
    this.color = AppColors.forest700,
    super.key,
  });
  final double size;
  final Color color;

  @override
  State<AppLoadingSpinner> createState() => _AppLoadingSpinnerState();
}

class _AppLoadingSpinnerState extends State<AppLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _SpinnerPainter(color: widget.color),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, paint);

    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 0.75,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. ERROR STATE & SHAKE
// ─────────────────────────────────────────────────────────────────────────────

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.errorMessage,
    required this.onRetry,
    this.onLogout,
    this.title = 'An anomaly occurred',
    super.key,
  });

  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onLogout;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.errorRed.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.errorRed,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontFamilyFallback: ['Liberation Serif', 'serif'],
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage,
              style: const TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                fontSize: 12,
                color: AppColors.ink900,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Retry Connection',
                    onPressed: onRetry,
                    variant: AppButtonVariant.outlined,
                    height: 38.0,
                  ),
                ),
                if (onLogout != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label:
                          AppLocalizations.of(context)?.commonSignOut ??
                          'Sign out',
                      onPressed: onLogout!,
                      variant: AppButtonVariant.filled,
                      height: 38.0,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppValidationShake extends StatefulWidget {
  const AppValidationShake({
    required this.child,
    required this.shouldShake,
    super.key,
  });

  final Widget child;
  final bool shouldShake;

  @override
  State<AppValidationShake> createState() => _AppValidationShakeState();
}

class _AppValidationShakeState extends State<AppValidationShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant AppValidationShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final progress = _ctrl.value;
        final offset =
            8.0 *
            (progress < 1.0
                ? (progress * 4.0 % 2 == 0 ? 1 : -1) * (1 - progress)
                : 0.0);

        return Transform.translate(
          offset: Offset(offset, 0.0),
          child: widget.child,
        );
      },
    );
  }
}

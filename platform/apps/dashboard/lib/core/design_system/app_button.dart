import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

enum AppButtonVariant {
  filled,
  outlined,
  text,
  gradient,
}

class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.height = 44.0,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool disabled;
  final double? width;
  final double height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _shimmerController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Color _getBgColor() {
    if (widget.disabled || widget.onPressed == null) {
      return AppColors.ink200;
    }
    return switch (widget.variant) {
      AppButtonVariant.filled =>
        _isHovered ? AppColors.forest500 : AppColors.forest700,
      AppButtonVariant.outlined => Colors.transparent,
      AppButtonVariant.text => Colors.transparent,
      AppButtonVariant.gradient => Colors.transparent,
    };
  }

  Color _getFgColor() {
    if (widget.disabled || widget.onPressed == null) {
      return AppColors.ink500;
    }
    return switch (widget.variant) {
      AppButtonVariant.filled => Colors.white,
      AppButtonVariant.outlined =>
        _isHovered ? AppColors.forest500 : AppColors.forest700,
      AppButtonVariant.text =>
        _isHovered ? AppColors.forest500 : AppColors.forest700,
      AppButtonVariant.gradient => Colors.white,
    };
  }

  Border? _getBorder() {
    if (widget.variant != AppButtonVariant.outlined) return null;
    final color = widget.disabled || widget.onPressed == null
        ? AppColors.ink200
        : (_isHovered ? AppColors.forest500 : AppColors.forest700);
    return Border.all(color: color, width: 1.5);
  }

  @override
  Widget build(BuildContext context) {
    final fg = _getFgColor();
    final bg = _getBgColor();
    final border = _getBorder();
    final hasCallback =
        widget.onPressed != null && !widget.disabled && !widget.isLoading;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 16, color: fg),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Calibri',
            fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );

    return MouseRegion(
      onEnter: hasCallback ? (_) => setState(() => _isHovered = true) : null,
      onExit: hasCallback ? (_) => setState(() => _isHovered = false) : null,
      cursor: hasCallback ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: hasCallback
            ? (_) {
                setState(() => _isPressed = true);
                if (widget.variant == AppButtonVariant.gradient) {
                  _shimmerController.forward(from: 0);
                }
              }
            : null,
        onTapUp: hasCallback ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel:
            hasCallback ? () => setState(() => _isPressed = false) : null,
        onTap: hasCallback ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeIn,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              border: border,
              borderRadius: BorderRadius.circular(8),
              gradient: (widget.variant == AppButtonVariant.gradient &&
                      hasCallback)
                  ? LinearGradient(
                      colors: [
                        _isHovered ? AppColors.forest500 : AppColors.forest700,
                        AppColors.forest500,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              boxShadow: (widget.variant == AppButtonVariant.filled ||
                          widget.variant == AppButtonVariant.gradient) &&
                      _isHovered &&
                      hasCallback
                  ? [
                      BoxShadow(
                        color: AppColors.forest700.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.variant == AppButtonVariant.gradient &&
                      hasCallback)
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin:
                                    Alignment(_shimmerAnimation.value - 1, 0),
                                end: Alignment(_shimmerAnimation.value, 0),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: buttonContent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

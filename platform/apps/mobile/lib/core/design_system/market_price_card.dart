import 'package:flutter/material.dart';
import '../models/market_price.dart';
import '../theme.dart';

/// Premium market price card with gold→forest gradient and a fade-in
/// animation when the price value changes.
class MarketPriceCard extends StatefulWidget {
  const MarketPriceCard({
    required this.marketPrice,
    this.cropIcon,
    this.onTap,
    this.entranceDelay = Duration.zero,
    super.key,
  });

  final MarketPrice marketPrice;
  final IconData? cropIcon;
  final VoidCallback? onTap;
  final Duration entranceDelay;

  @override
  State<MarketPriceCard> createState() => _MarketPriceCardState();
}

class _MarketPriceCardState extends State<MarketPriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    if (widget.entranceDelay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.entranceDelay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant MarketPriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Replay fade when the price value changes (micro-animation on update)
    if (oldWidget.marketPrice.price != widget.marketPrice.price) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _unavailable => widget.marketPrice.price == 0;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: widget.onTap != null
              ? (_) => setState(() => _isPressed = true)
              : null,
          onTapUp: widget.onTap != null
              ? (_) => setState(() => _isPressed = false)
              : null,
          onTapCancel: widget.onTap != null
              ? () => setState(() => _isPressed = false)
              : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: _isPressed
                ? const Duration(milliseconds: 60)
                : const Duration(milliseconds: 150),
            curve: _isPressed ? Curves.easeIn : Curves.easeOutBack,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                gradient: _unavailable
                    ? null
                    : const LinearGradient(
                        colors: [
                          Color(0xFFF5E6C0), // gold200
                          Color(0xFFEAF4EE), // forest100
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: _unavailable ? AppColors.cream100 : null,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _unavailable
                      ? AppColors.ink200
                      : AppColors.gold600.withValues(alpha: 0.35),
                  width: 1,
                ),
                boxShadow: _unavailable
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.forest900.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // ── Crop icon badge ────────────────────────────────
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _unavailable
                            ? AppColors.ink200.withValues(alpha: 0.3)
                            : AppColors.forest700.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          widget.cropIcon ?? Icons.spa_rounded,
                          color: _unavailable
                              ? AppColors.ink500
                              : AppColors.forest700,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // ── Crop name + source ─────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.marketPrice.cropName,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontFamilyFallback: ['Liberation Serif', 'serif'],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.marketPrice.source,
                            style: const TextStyle(
                              fontFamily: 'Calibri',
                              fontFamilyFallback: [
                                'Liberation Sans',
                                'sans-serif',
                              ],
                              fontSize: 11,
                              color: AppColors.ink500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Updated ${widget.marketPrice.lastUpdatedLabel}',
                            style: TextStyle(
                              fontFamily: 'Calibri',
                              fontFamilyFallback: const [
                                'Liberation Sans',
                                'sans-serif',
                              ],
                              fontSize: 10,
                              color: AppColors.ink500.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Price ─────────────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_unavailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ink200.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'N/A',
                              style: TextStyle(
                                fontFamily: 'Calibri',
                                fontFamilyFallback: [
                                  'Liberation Sans',
                                  'sans-serif',
                                ],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink500,
                              ),
                            ),
                          )
                        else ...[
                          Text(
                            '${widget.marketPrice.currency} ${_formatPrice(widget.marketPrice.price)}',
                            style: const TextStyle(
                              fontFamily: 'Calibri',
                              fontFamilyFallback: [
                                'Liberation Sans',
                                'sans-serif',
                              ],
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forest700,
                            ),
                          ),
                          Text(
                            '/ ${widget.marketPrice.unit}',
                            style: const TextStyle(
                              fontFamily: 'Calibri',
                              fontFamilyFallback: [
                                'Liberation Sans',
                                'sans-serif',
                              ],
                              fontSize: 11,
                              color: AppColors.ink500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    }
    return price.toStringAsFixed(2);
  }
}

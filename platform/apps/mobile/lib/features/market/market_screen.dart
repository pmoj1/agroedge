import 'dart:async';

import 'package:agroedge_shared/models/farm-profile.dart';
import 'package:flutter/material.dart';

import '../../core/design_system/app_button.dart';
import '../../core/design_system/market_price_card.dart';
import '../../core/models/market_price.dart';
import '../../core/services/market_service.dart';
import '../../core/theme.dart';

/// Market tab — shows live crop prices for the farmer's registered crops,
/// sourced from the Grain Marketing Board of their country (via WFP VAM API
/// with country-specific static fallback).
class MarketScreen extends StatefulWidget {
  const MarketScreen({required this.profilesFuture, super.key});

  final Future<List<FarmProfile>> profilesFuture;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<MarketPrice> _prices = [];
  bool _loading = true;
  String? _error;
  FarmProfile? _profile;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    // Auto-refresh every 30 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _load(forceRefresh: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profiles = await widget.profilesFuture;
      if (profiles.isEmpty) {
        setState(() {
          _loading = false;
          _profile = null;
          _prices = [];
        });
        return;
      }

      _profile = profiles.first;
      final crops = _profile!.selectedCrops;
      final country = _profile!.country ?? 'ZW';

      final prices = await MarketService.instance.fetchCurrentPrices(
        crops: crops,
        countryCode: country,
      );

      if (mounted) {
        setState(() {
          _prices = prices;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF000000)
          : AppColors.cream100,
      body: RefreshIndicator(
        onRefresh: () => _load(forceRefresh: true),
        color: AppColors.forest700,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            if (_loading)
              const SliverFillRemaining(child: _LoadingView())
            else if (_error != null)
              SliverFillRemaining(
                child: _ErrorView(error: _error!, onRetry: _load),
              )
            else if (_profile == null)
              const SliverFillRemaining(child: _NoProfileView())
            else if (_prices.isEmpty)
              const SliverFillRemaining(child: _NoCropsView())
            else
              _buildPriceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final country = _profile?.country ?? '';
    final countryName = MarketService.countryNameFor(country);
    final farmName = _profile?.farmName ?? 'Your Farm';

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.forest900,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Prices',
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['Liberation Serif', 'serif'],
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_profile != null)
              Text(
                '$farmName · $countryName',
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F3020), // forest900
                Color(0xFF164E33), // forest700
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 48, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'LIVE PRICING',
                    style: TextStyle(
                      fontFamily: 'Calibri',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Color(0xFFBD943A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Auto-refreshes every 30 min',
                    style: TextStyle(
                      fontFamily: 'Calibri',
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Refresh prices',
          onPressed: () => _load(forceRefresh: true),
        ),
      ],
    );
  }

  Widget _buildPriceList() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) return _buildInfoBanner();
            if (index == 1) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'YOUR CROPS',
                  style: TextStyle(
                    fontFamily: 'Calibri',
                    fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink500,
                    letterSpacing: 1.4,
                  ),
                ),
              );
            }
            final priceIndex = index - 2;
            if (priceIndex < _prices.length) {
              return MarketPriceCard(
                marketPrice: _prices[priceIndex],
                entranceDelay: Duration(milliseconds: 60 * priceIndex),
              );
            }
            if (index == _prices.length + 2) {
              return _buildDisclaimerFooter();
            }
            return null;
          },
          childCount: _prices.length + 3, // banner + header + prices + footer
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gold200.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold600.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.gold600, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Prices sourced from official Grain Marketing Boards & WFP market data. '
              'For indicative purposes only.',
              style: const TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                fontSize: 11,
                color: AppColors.ink500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Market data provided via WFP VAM Food Security database.\n'
            'Prices are indicative and may vary at local markets.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Calibri',
              fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
              fontSize: 10,
              color: AppColors.ink500.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inner state widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.forest700),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Fetching market prices…',
            style: TextStyle(
              fontFamily: 'Calibri',
              fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
              fontSize: 14,
              color: AppColors.ink500.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AppColors.ink200,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Market data unavailable',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['Liberation Serif', 'serif'],
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We couldn\'t reach the market data service. '
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                fontSize: 14,
                color: AppColors.ink500.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Try Again',
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Set up your farm first',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['Liberation Serif', 'serif'],
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete your farm profile to see market prices for your crops.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                fontSize: 14,
                color: AppColors.ink500.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCropsView extends StatelessWidget {
  const _NoCropsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌾', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No crops registered',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['Liberation Serif', 'serif'],
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add a primary or secondary crop to your farm profile '
              'to see current market prices here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                fontSize: 14,
                color: AppColors.ink500.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agroedge_shared/models/farm-profile.dart';

import '../../core/app_services.dart';
import '../../core/design_system/app_card.dart';
import '../../core/design_system/app_states.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme.dart';

class BusinessInsightTab extends StatefulWidget {
  const BusinessInsightTab({super.key});

  @override
  State<BusinessInsightTab> createState() => _BusinessInsightTabState();
}

class _BusinessInsightTabState extends State<BusinessInsightTab> {
  late Future<List<dynamic>> _insightFuture;
  String? _cachedBriefing;
  bool _loadingBriefing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _insightFuture = _fetchWorldBankMetrics();
  }

  Future<List<dynamic>> _fetchWorldBankMetrics() async {
    final profiles = await AppServices.instance.farmProfiles.list();
    final profile = profiles.isNotEmpty ? profiles.first : null;
    final countryName = profile?.country ?? 'Zimbabwe';

    // Default fallback mappings
    String countryCode = 'ZW';
    if (countryName.toLowerCase().contains('zambia')) {
      countryCode = 'ZM';
    } else if (countryName.toLowerCase().contains('kenya')) {
      countryCode = 'KE';
    } else if (countryName.toLowerCase().contains('south africa')) {
      countryCode = 'ZA';
    } else if (countryName.toLowerCase().contains('tanzania')) {
      countryCode = 'TZ';
    } else if (countryName.toLowerCase().contains('mozambique')) {
      countryCode = 'MZ';
    } else if (countryName.toLowerCase().contains('malawi')) {
      countryCode = 'MW';
    } else if (countryName.toLowerCase().contains('botswana')) {
      countryCode = 'BW';
    }

    // Fetch three indicators in parallel
    final results = await Future.wait([
      _fetchIndicator(countryCode, 'SP.RUR.TOTL'), // Rural population
      _fetchIndicator(countryCode, 'NV.AGR.TOTL.ZS'), // Ag value added % GDP
      _fetchIndicator(countryCode, 'AG.YLD.CREL.KG'), // Cereal yields (kg/ha)
      // SSA averages for comparison
      _fetchIndicator('SSF', 'NV.AGR.TOTL.ZS'),
      _fetchIndicator('SSF', 'AG.YLD.CREL.KG'),
    ]);

    final ruralPop = results[0];
    final agGdp = results[1];
    final cerealYield = results[2];
    final ssaAgGdp = results[3];
    final ssaCerealYield = results[4];

    // Trigger AI Briefing fetch in background
    if (_cachedBriefing == null && !_loadingBriefing) {
      _fetchAiBriefing(countryName, agGdp, cerealYield, ruralPop);
    }

    return [profile, ruralPop, agGdp, cerealYield, ssaAgGdp, ssaCerealYield];
  }

  Future<double?> _fetchIndicator(String country, String indicator) async {
    final cacheKey = 'wb_cache_${country}_$indicator';
    final prefs = await SharedPreferences.getInstance();

    // Check client TTL cache (6 hours for World Bank indicator data)
    final cachedVal = prefs.getDouble(cacheKey);
    final cachedTime = prefs.getInt('${cacheKey}_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedVal != null &&
        (now - cachedTime) < const Duration(hours: 6).inMilliseconds) {
      return cachedVal;
    }

    try {
      final url = Uri.parse(
        'https://api.worldbank.org/v2/country/$country/indicator/$indicator?format=json&per_page=5',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body is List && body.length > 1 && body[1] is List) {
          final observations = body[1] as List;
          for (final obs in observations) {
            final val = obs['value'];
            if (val != null) {
              final doubleVal = (val as num).toDouble();
              // Cache settings locally
              await prefs.setDouble(cacheKey, doubleVal);
              await prefs.setInt('${cacheKey}_time', now);
              return doubleVal;
            }
          }
        }
      }
    } catch (_) {}

    // Graceful fallback to offline cache even if TTL expired
    return cachedVal;
  }

  Future<void> _fetchAiBriefing(
    String country,
    double? agGdp,
    double? cerealYield,
    double? ruralPop,
  ) async {
    setState(() => _loadingBriefing = true);
    final prompt =
        'Given these national agricultural indicators for $country:\n'
        '- Cereal yield: ${cerealYield?.toStringAsFixed(0) ?? "Unknown"} kg/hectare\n'
        '- Agricultural contribution to GDP: ${agGdp?.toStringAsFixed(1) ?? "Unknown"}%\n'
        '- Rural population: ${ruralPop != null ? NumberFormat.compact().format(ruralPop) : "Unknown"}\n\n'
        'Provide a concise 2-sentence agronomist briefing explaining what these macro trends mean for a smallholder farmer in this country.';

    try {
      final advice = await AIService.instance.complete(
        prompt,
        systemInstruction:
            'You are a senior agricultural economist. Keep your response to exactly two clear sentences.',
      );
      if (mounted) {
        setState(() {
          _cachedBriefing = advice;
          _loadingBriefing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingBriefing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<dynamic>>(
      future: _insightFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.forest700),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: AppErrorState(
              title: 'Could not load snapshots',
              errorMessage: 'Ensure your device is connected to the internet.',
              onRetry: () => setState(() => _loadData()),
            ),
          );
        }

        final data = snapshot.data!;
        final profile = data[0] as FarmProfile?;
        final ruralPop = data[1] as double?;
        final agGdp = data[2] as double?;
        final cerealYield = data[3] as double?;
        final ssaAgGdp = data[4] as double?;
        final ssaCerealYield = data[5] as double?;

        final countryName = profile?.country ?? 'Zimbabwe';

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0E1A14)
              : AppColors.cream100,
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _cachedBriefing = null;
                _loadData();
              });
            },
            color: AppColors.forest700,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Insights',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontFamilyFallback: const ['Liberation Serif', 'serif'],
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFBF4E4)
                            : AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'World Bank country profiles and regional comparative analytics',
                      style: TextStyle(
                        fontFamily: 'Calibri',
                        fontFamilyFallback: const [
                          'Liberation Sans',
                          'sans-serif',
                        ],
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFA8B5AC)
                            : AppColors.ink500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // World Bank Snapshot Card
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.public_rounded,
                              color: isDark
                                  ? const Color(0xFF3E8E5E)
                                  : AppColors.forest700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$countryName Snapshot',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? const Color(0xFFFBF4E4)
                                    : AppColors.ink900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildMetricRow(
                          'Cereal Yield',
                          cerealYield != null
                              ? '${NumberFormat.decimalPattern().format(cerealYield.round())} kg/ha'
                              : 'Unavailable',
                          'Average grain production efficiency',
                          isDark,
                        ),
                        const Divider(height: AppSpacing.lg),
                        _buildMetricRow(
                          'Agricultural GDP Share',
                          agGdp != null
                              ? '${agGdp.toStringAsFixed(1)}%'
                              : 'Unavailable',
                          'Sector contribution to domestic product',
                          isDark,
                        ),
                        const Divider(height: AppSpacing.lg),
                        _buildMetricRow(
                          'Rural Population',
                          ruralPop != null
                              ? NumberFormat.decimalPattern().format(
                                  ruralPop.round(),
                                )
                              : 'Unavailable',
                          'Total population residing in rural regions',
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // SSA Regional Comparison Card
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.compare_arrows_rounded,
                              color: isDark
                                  ? const Color(0xFF3E8E5E)
                                  : AppColors.forest700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Regional Comparison',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? const Color(0xFFFBF4E4)
                                    : AppColors.ink900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Comparing $countryName against Sub-Saharan Africa (SSA) benchmarks:',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFFA8B5AC)
                                : AppColors.ink500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildComparisonBar(
                          'Cereal Yield (kg/ha)',
                          cerealYield ?? 0,
                          ssaCerealYield ?? 1500,
                          isDark,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildComparisonBar(
                          'Ag GDP Share (%)',
                          agGdp ?? 0,
                          ssaAgGdp ?? 15.0,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // AI Agronomist Briefing
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              color: AppColors.gold500,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Macro Insights Briefing',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? const Color(0xFFFBF4E4)
                                    : AppColors.ink900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_loadingBriefing)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: AppColors.forest700,
                              ),
                            ),
                          )
                        else if (_cachedBriefing != null)
                          Text(
                            _cachedBriefing!,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: isDark
                                  ? const Color(0xFFFBF4E4)
                                  : AppColors.ink900,
                            ),
                          )
                        else
                          Text(
                            'AI insights requires an internet connection.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFA8B5AC)
                                  : AppColors.ink500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Sources footer
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    'Data Sources: World Bank Open Data API.\nLast updated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? const Color(0x66FFFFFF)
                          : AppColors.ink500.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(String label, String value, String desc, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? const Color(0xFFFBF4E4) : AppColors.ink900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFFA8B5AC) : AppColors.ink500,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? const Color(0xFF3E8E5E) : AppColors.forest700,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonBar(
    String title,
    double current,
    double comparison,
    bool isDark,
  ) {
    final double maxVal = math.max(current, comparison);
    final currentPercent = maxVal > 0 ? (current / maxVal) : 0.0;
    final comparisonPercent = maxVal > 0 ? (comparison / maxVal) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isDark ? const Color(0xFFFBF4E4) : AppColors.ink900,
          ),
        ),
        const SizedBox(height: 8),
        // Active Country Bar
        Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                'This Country',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFFA8B5AC) : AppColors.ink500,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B2E22)
                          : const Color(0xFFF0EAE1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: currentPercent.clamp(0.02, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3E8E5E)
                            : AppColors.forest700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                current.toStringAsFixed(0),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isDark ? const Color(0xFFFBF4E4) : AppColors.ink900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // SSA Benchmark Bar
        Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                'SSA Average',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFFA8B5AC) : AppColors.ink500,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B2E22)
                          : const Color(0xFFF0EAE1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: comparisonPercent.clamp(0.02, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.gold500,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                comparison.toStringAsFixed(0),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isDark ? const Color(0xFFFBF4E4) : AppColors.ink900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

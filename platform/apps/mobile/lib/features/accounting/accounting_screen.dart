import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:agroedge_shared/models/activity.dart';
import 'package:agroedge_shared/models/expense.dart';
import 'package:agroedge_shared/models/income-record.dart';
import 'package:agroedge_shared/models/farm-profile.dart';
import '../../core/app_services.dart';
import '../../core/design_system/app_card.dart';
import '../../core/design_system/app_states.dart';
import '../../core/services/gemini_service.dart';
import '../../core/data/country_data.dart';
import '../../core/theme.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({
    this.selectedPeriod = 'This Month',
    this.customRange,
    super.key,
  });

  final String selectedPeriod;
  final DateTimeRange? customRange;

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  late Future<List<dynamic>> _dataFuture;
  String? _cachedAdvice;
  bool _isLoadingAdvice = false;

  List<T> _filterByPeriod<T>(List<T> items, DateTime Function(T) getDate) {
    final now = DateTime.now();
    final period = widget.selectedPeriod;
    final range = widget.customRange;

    if (period == 'This Month') {
      return items.where((item) {
        final date = getDate(item);
        return date.year == now.year && date.month == now.month;
      }).toList();
    } else if (period == 'This Week') {
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      return items
          .where((item) => getDate(item).isAfter(sevenDaysAgo))
          .toList();
    } else if (period == 'This Season') {
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));
      return items
          .where((item) => getDate(item).isAfter(ninetyDaysAgo))
          .toList();
    } else if (period == 'This Year') {
      return items.where((item) => getDate(item).year == now.year).toList();
    } else if (period == 'Custom range' && range != null) {
      return items.where((item) {
        final date = getDate(item);
        return date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(range.end.add(const Duration(days: 1)));
      }).toList();
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = Future.wait([
      AppServices.instance.expenses.list(),
      AppServices.instance.incomeRecords.list(),
      AppServices.instance.farmProfiles.list(),
      AppServices.instance.activities.list(),
    ]);
  }

  Future<void> _fetchAiAdvice(
    double totalIncome,
    double totalExpenses,
    double netProfit,
    double creditScore,
    String country,
    List<String> crops,
  ) async {
    if (_cachedAdvice != null) return;
    setState(() => _isLoadingAdvice = true);
    try {
      final advice = await GeminiService.instance.generateAccountingAdvice(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        netProfit: netProfit,
        creditScore: creditScore,
        country: country,
        crops: crops,
      );
      setState(() {
        _cachedAdvice = advice;
        _isLoadingAdvice = false;
      });
    } catch (_) {
      setState(() => _isLoadingAdvice = false);
    }
  }

  double _calculateCreditScore({
    required double totalIncome,
    required double totalExpenses,
    required double netProfit,
    required int activitiesCount,
    required int recordsCount,
  }) {
    // Credit scoring model tailored for smallholder farmers
    // Range: 300 to 1000
    double score = 300.0;

    // 1. Profit-to-revenue ratio (up to 300 points)
    if (totalIncome > 0) {
      final ratio = netProfit / totalIncome;
      if (ratio > 0) {
        score += math.min(ratio * 300, 300);
      }
    }

    // 2. Consistency: logged activities (up to 150 points)
    score += math.min(activitiesCount * 15.0, 150.0);

    // 3. Consistency: accounting history/records (up to 150 points)
    score += math.min(recordsCount * 20.0, 150.0);

    // 4. Positive profitability bonus (100 points)
    if (netProfit > 0) {
      score += 100.0;
    }

    return score;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.forest700),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: AppErrorState(
              title: 'Failed to load accounts',
              errorMessage:
                  snapshot.error?.toString() ?? 'Something went wrong.',
              onRetry: () => setState(() => _loadData()),
            ),
          );
        }

        final rawExpenses = snapshot.data![0] as List<Expense>;
        final rawIncomes = snapshot.data![1] as List<IncomeRecord>;
        final profiles = snapshot.data![2] as List<FarmProfile>;
        final rawActivities = snapshot.data![3] as List<Activity>;

        final expenses = _filterByPeriod(rawExpenses, (e) => e.expenseDate);
        final incomes = _filterByPeriod(rawIncomes, (i) => i.incomeDate);
        final activities = _filterByPeriod(
          rawActivities,
          (a) => a.activityDate,
        );

        final profile = profiles.isNotEmpty ? profiles.first : null;
        final countryName = profile?.country ?? 'Zimbabwe';
        final countryData = CountryData.findByName(countryName);
        final currencyCode = countryData?.currency ?? 'USD';

        final totalIncome = incomes.fold<double>(
          0.0,
          (sum, item) => sum + (item.totalRevenue ?? 0).toDouble(),
        );
        final totalExpenses = expenses.fold<double>(
          0.0,
          (sum, item) => sum + item.amount.toDouble(),
        );
        final netProfit = totalIncome - totalExpenses;
        final grossMargin = totalIncome > 0
            ? (netProfit / totalIncome) * 100
            : 0.0;

        final creditScore = _calculateCreditScore(
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          netProfit: netProfit,
          activitiesCount: activities.length,
          recordsCount: expenses.length + incomes.length,
        );

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
        final mutedTextColor = isDark
            ? const Color(0xFFA8B5AC)
            : AppColors.ink500;

        final crops = [
          profile?.primaryCrop,
          profile?.secondaryCrop,
        ].whereType<String>().toList();

        // Trigger AI advice fetching in background
        if (!_isLoadingAdvice && _cachedAdvice == null) {
          _fetchAiAdvice(
            totalIncome,
            totalExpenses,
            netProfit,
            creditScore,
            countryName,
            crops.isEmpty ? ['General crops'] : crops,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _cachedAdvice = null;
              _loadData();
            });
          },
          color: AppColors.forest700,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm Ledger & Accounting',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontFamilyFallback: const ['Liberation Serif', 'serif'],
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-Powered agricultural credit scoring and cash flow analytics',
                      style: TextStyle(
                        fontFamily: 'Calibri',
                        fontFamilyFallback: const [
                          'Liberation Sans',
                          'sans-serif',
                        ],
                        fontSize: 12,
                        color: mutedTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Credit Score Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: isDark
                              ? const Color(0xFF3E8E5E)
                              : AppColors.forest700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Credit Eligibility Score',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 120,
                      width: 200,
                      child: CustomPaint(
                        painter: CreditScoreGaugePainter(
                          score: creditScore - 300,
                          maxScore: 700,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              creditScore.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.forest900,
                              ),
                            ),
                            Text(
                              _getCreditScoreRating(creditScore),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getCreditScoreColor(creditScore),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Calculated using your farm records, income ratios, and activity logging consistency. Banks use this to evaluate microfinance loans.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.ink500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 2. Gross profit margin & outstanding invoices grid
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Profit Margin',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.ink500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                Icons.pie_chart_outline_rounded,
                                color: AppColors.forest700,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${grossMargin.toInt()}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forest700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            netProfit >= 0
                                ? 'Healthy Margin'
                                : 'Negative Margin',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: netProfit >= 0
                                  ? AppColors.forest500
                                  : AppColors.errorRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ledger Health',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.ink500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.forest700,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            currencyCode,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forest700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Country: $countryName',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.ink500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 3. Cash Flow Chart Card
              AppCard(
                backgroundColor: const Color(
                  0xFF2C3E2B,
                ), // Dark forest/slate bg like reference image
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cash Flow Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.selectedPeriod,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$currencyCode ${NumberFormat.decimalPattern().format(totalIncome)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Builder(
                      builder: (context) {
                        final DateTime startDate;
                        final DateTime endDate = DateTime.now();
                        final String period = widget.selectedPeriod;

                        if (period == 'This Week') {
                          startDate = endDate.subtract(const Duration(days: 6));
                        } else if (period == 'This Month') {
                          startDate = DateTime(endDate.year, endDate.month, 1);
                        } else if (period == 'This Season') {
                          startDate = endDate.subtract(
                            const Duration(days: 90),
                          );
                        } else if (period == 'This Year') {
                          startDate = DateTime(endDate.year, 1, 1);
                        } else if (period == 'Custom range' &&
                            widget.customRange != null) {
                          startDate = widget.customRange!.start;
                        } else {
                          startDate = endDate.subtract(
                            const Duration(days: 30),
                          );
                        }

                        final int bucketCount = 6;
                        final duration = endDate.difference(startDate);
                        final double intervalDays =
                            (duration.inDays / bucketCount).clamp(1.0, 365.0);

                        final List<Widget> bars = [];

                        for (int i = 0; i < bucketCount; i++) {
                          final bucketStart = startDate.add(
                            Duration(days: (i * intervalDays).round()),
                          );
                          final bucketEnd = bucketStart.add(
                            Duration(days: intervalDays.round()),
                          );

                          final double bucketIncome = incomes
                              .where(
                                (item) =>
                                    item.incomeDate.isAfter(
                                      bucketStart.subtract(
                                        const Duration(seconds: 1),
                                      ),
                                    ) &&
                                    item.incomeDate.isBefore(
                                      bucketEnd.add(const Duration(seconds: 1)),
                                    ),
                              )
                              .fold(
                                0.0,
                                (sum, item) =>
                                    sum + (item.totalRevenue ?? 0).toDouble(),
                              );

                          final double bucketExpense = expenses
                              .where(
                                (item) =>
                                    item.expenseDate.isAfter(
                                      bucketStart.subtract(
                                        const Duration(seconds: 1),
                                      ),
                                    ) &&
                                    item.expenseDate.isBefore(
                                      bucketEnd.add(const Duration(seconds: 1)),
                                    ),
                              )
                              .fold(
                                0.0,
                                (sum, item) => sum + item.amount.toDouble(),
                              );

                          final label = DateFormat('d MMM').format(bucketStart);

                          bars.add(
                            _buildBar(label, bucketIncome, bucketExpense),
                          );
                        }

                        final bool hasAnyData =
                            incomes.isNotEmpty || expenses.isNotEmpty;

                        if (!hasAnyData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No cash flow records logged in this period.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: bars,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Income',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Expenses',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 3.5. Crop Performance Analysis Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: AppColors.forest700,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Crop Revenue Performance',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (incomes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Log sales transactions to analyze crop performance.',
                            style: TextStyle(
                              color: AppColors.ink500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      Builder(
                        builder: (context) {
                          final Map<String, double> cropRevenue = {};
                          for (final inc in incomes) {
                            var crop = inc.crop?.trim() ?? '';
                            if (crop.isEmpty || double.tryParse(crop) != null) {
                              crop = profile?.primaryCrop ?? 'Maize';
                            }
                            cropRevenue[crop] =
                                (cropRevenue[crop] ?? 0.0) +
                                (inc.totalRevenue ?? 0).toDouble();
                          }

                          if (cropRevenue.isEmpty) {
                            return const Text(
                              'No crop-specific income found.',
                              style: TextStyle(
                                color: AppColors.ink500,
                                fontSize: 12,
                              ),
                            );
                          }

                          final sortedCrops = cropRevenue.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));

                          final bestCrop = sortedCrops.first.key;
                          final bestCropVal = sortedCrops.first.value;
                          final leastCrop = sortedCrops.last.key;
                          final leastCropVal = sortedCrops.last.value;

                          final maxVal = bestCropVal > 0 ? bestCropVal : 1.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.forest100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '🥇 TOP PERFORMING',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.forest700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            bestCrop,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.ink900,
                                            ),
                                          ),
                                          Text(
                                            '$currencyCode ${bestCropVal.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.forest700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.clay400.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '⚠️ LEAST PERFORMING',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.clay400,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            leastCrop,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.ink900,
                                            ),
                                          ),
                                          Text(
                                            '$currencyCode ${leastCropVal.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.clay400,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const Text(
                                'CROP REVENUE SHARE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ...sortedCrops.map((entry) {
                                final percentage = (entry.value / maxVal);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            entry.key,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '$currencyCode ${entry.value.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.ink500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percentage,
                                          minHeight: 8,
                                          backgroundColor: const Color(
                                            0xFFE5DDD0,
                                          ),
                                          color: entry.key == bestCrop
                                              ? AppColors.forest500
                                              : AppColors.gold500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Builder(
                builder: (context) {
                  // Calculate both income and expenses per crop
                  final Map<String, double> cropIncome = {};
                  final Map<String, double> cropExpense = {};

                  // Parse incomes
                  for (final inc in incomes) {
                    var crop = inc.crop?.trim() ?? '';
                    if (crop.isEmpty || double.tryParse(crop) != null) {
                      crop = profile?.primaryCrop ?? 'Maize';
                    }
                    cropIncome[crop] =
                        (cropIncome[crop] ?? 0.0) +
                        (inc.totalRevenue ?? 0).toDouble();
                  }

                  // Parse expenses
                  for (final exp in expenses) {
                    String matchedCrop = 'General Operations';
                    final noteLower = (exp.notes ?? '').toLowerCase();
                    final catLower = (exp.category ?? '').toLowerCase();

                    for (final c in crops) {
                      final cLower = c.toLowerCase();
                      if (noteLower.contains(cLower) ||
                          catLower.contains(cLower)) {
                        matchedCrop = c;
                        break;
                      }
                    }
                    cropExpense[matchedCrop] =
                        (cropExpense[matchedCrop] ?? 0.0) +
                        exp.amount.toDouble();
                  }

                  final allCrops = <String>{
                    ...cropIncome.keys,
                    ...cropExpense.keys,
                  }.toList();

                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assignment_turned_in_rounded,
                              color: isDark
                                  ? const Color(0xFF3E8E5E)
                                  : AppColors.forest700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Crop Profitability Breakdown',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (allCrops.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Log transactions to analyze crop profitability.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                        else
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1.2),
                              2: FlexColumnWidth(1.2),
                              3: FlexColumnWidth(1.2),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Text(
                                    'Crop',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: mutedTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Revenue',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: mutedTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Expenses',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: mutedTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Net Profit',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: mutedTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              ...allCrops.map((c) {
                                final rev = cropIncome[c] ?? 0.0;
                                final exp = cropExpense[c] ?? 0.0;
                                final net = rev - exp;
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Text(
                                        c,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Text(
                                        '$currencyCode${rev.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Text(
                                        '$currencyCode${exp.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Text(
                                        '$currencyCode${net.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: net >= 0
                                              ? AppColors.forest500
                                              : AppColors.errorRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              const BreakEvenCalculatorWidget(),

              const SizedBox(height: AppSpacing.md),

              // 4. AI Tailored Financial/Accounting Advice
              AppCard(
                backgroundColor: AppColors.cream100,
                borderColor: const Color(0xFFE5DDD0),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          color: AppColors.gold600,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI Accounting Recommendations',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_isLoadingAdvice)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: CircularProgressIndicator(
                            color: AppColors.forest700,
                          ),
                        ),
                      )
                    else if (_cachedAdvice != null)
                      MarkdownBody(
                        data: _cachedAdvice!,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              p: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: AppColors.ink900,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.forest900,
                              ),
                            ),
                      )
                    else
                      const Text(
                        'AI advice is currently unavailable. Tap refresh above to retry.',
                        style: TextStyle(fontSize: 12, color: AppColors.ink500),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 5. Invoices Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  'RECENT TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink500,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (expenses.isEmpty && incomes.isEmpty)
                AppCard(
                  child: const Center(
                    child: Text(
                      'No ledger transactions recorded yet.',
                      style: TextStyle(color: AppColors.ink500, fontSize: 13),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    ...incomes.take(3).map((inc) {
                      var displayCrop = inc.crop?.trim() ?? '';
                      if (displayCrop.isEmpty ||
                          double.tryParse(displayCrop) != null) {
                        displayCrop = profile?.primaryCrop ?? 'Crop Sale';
                      }
                      return _buildInvoiceItem(
                        title: displayCrop,
                        subtitle: inc.buyer ?? 'Direct sale',
                        amount: '+${inc.totalRevenue} $currencyCode',
                        status: 'Completed',
                        statusColor: AppColors.forest500,
                        date: DateFormat.yMMMd().format(inc.incomeDate),
                      );
                    }),
                    ...expenses
                        .take(3)
                        .map(
                          (exp) => _buildInvoiceItem(
                            title: exp.category ?? 'Farm Supply',
                            subtitle: exp.notes ?? 'General expense',
                            amount: '-${exp.amount} $currencyCode',
                            status: 'Completed',
                            statusColor: AppColors.forest500,
                            date: DateFormat.yMMMd().format(exp.expenseDate),
                          ),
                        ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(String label, double incomeVal, double expenseVal) {
    // Normalize heights
    final double totalMax = math.max(incomeVal, expenseVal);
    final double incomeHeight = totalMax > 0
        ? (incomeVal / totalMax) * 60
        : 0.0;
    final double expenseHeight = totalMax > 0
        ? (expenseVal / totalMax) * 60
        : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 8,
              height: math.max(incomeHeight, 6.0),
              decoration: BoxDecoration(
                color: AppColors.gold500,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 3),
            Container(
              width: 8,
              height: math.max(expenseHeight, 6.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
      ],
    );
  }

  Widget _buildInvoiceItem({
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required Color statusColor,
    required String date,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14261C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF0EAE1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDark
                ? const Color(0xFF1B2E22)
                : const Color(0xFFF9F7F4),
            radius: 20,
            child: Icon(
              amount.startsWith('+')
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: amount.startsWith('+')
                  ? (isDark ? const Color(0xFF3E8E5E) : AppColors.forest700)
                  : AppColors.clay400,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? const Color(0xFFFBF4E4) : AppColors.ink900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFA8B5AC) : AppColors.ink500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: amount.startsWith('+')
                      ? (isDark ? const Color(0xFF3E8E5E) : AppColors.forest700)
                      : AppColors.errorRed,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: isDark ? const Color(0xFFA8B5AC) : AppColors.ink500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCreditScoreRating(double score) {
    if (score >= 850) return 'Excellent';
    if (score >= 700) return 'Very Good';
    if (score >= 550) return 'Good';
    if (score >= 400) return 'Fair';
    return 'Poor';
  }

  Color _getCreditScoreColor(double score) {
    if (score >= 700) return AppColors.forest700;
    if (score >= 550) return AppColors.gold600;
    return AppColors.errorRed;
  }
}

class CreditScoreGaugePainter extends CustomPainter {
  CreditScoreGaugePainter({required this.score, required this.maxScore});
  final double score;
  final double maxScore;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 12;

    // Track arc
    final trackPaint = Paint()
      ..color = const Color(0xFFE5DDD0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Active arc (gradient)
    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.gold500, AppColors.forest500, AppColors.forest700],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.min((score / maxScore) * math.pi, math.pi);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BreakEvenCalculatorWidget extends StatefulWidget {
  const BreakEvenCalculatorWidget({super.key});

  @override
  State<BreakEvenCalculatorWidget> createState() =>
      _BreakEvenCalculatorWidgetState();
}

class _BreakEvenCalculatorWidgetState extends State<BreakEvenCalculatorWidget> {
  double _fixedCosts = 250.0;
  double _salePricePerUnit = 2.50;
  double _variableCostPerUnit = 0.80;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
    final mutedTextColor = isDark ? const Color(0xFFA8B5AC) : AppColors.ink500;

    final unitContribution = _salePricePerUnit - _variableCostPerUnit;
    final breakEvenVolume = unitContribution > 0
        ? _fixedCosts / unitContribution
        : 0.0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                color: isDark ? const Color(0xFF3E8E5E) : AppColors.forest700,
              ),
              const SizedBox(width: 8),
              Text(
                'Break-Even Simulator',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Determine how many units of crop you need to sell to cover your seasonal input and overhead costs.',
            style: TextStyle(fontSize: 12, color: mutedTextColor),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSlider(
            label: 'Seasonal Fixed Costs (Rent, Tools)',
            value: _fixedCosts,
            min: 50.0,
            max: 2000.0,
            symbol: r'$',
            onChanged: (val) => setState(() => _fixedCosts = val),
          ),
          _buildSlider(
            label: 'Sale Price per unit (e.g. per KG)',
            value: _salePricePerUnit,
            min: 0.50,
            max: 10.00,
            symbol: r'$',
            onChanged: (val) => setState(() => _salePricePerUnit = val),
          ),
          _buildSlider(
            label: 'Variable Cost per unit (Seed, Fertilizer)',
            value: _variableCostPerUnit,
            min: 0.10,
            max: 5.00,
            symbol: r'$',
            onChanged: (val) => setState(() => _variableCostPerUnit = val),
          ),
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2E22) : AppColors.forest100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BREAK-EVEN TARGET',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF3E8E5E)
                              : AppColors.forest700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Target Volume to Recover Costs',
                        style: TextStyle(fontSize: 11, color: mutedTextColor),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${breakEvenVolume.toStringAsFixed(1)} units',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFF3E8E5E)
                        : AppColors.forest700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String symbol,
    required ValueChanged<double> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Text(
              '$symbol${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: isDark
                ? const Color(0xFF3E8E5E)
                : AppColors.forest700,
            thumbColor: isDark ? const Color(0xFF3E8E5E) : AppColors.forest700,
            overlayColor:
                (isDark ? const Color(0xFF3E8E5E) : AppColors.forest700)
                    .withValues(alpha: 0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

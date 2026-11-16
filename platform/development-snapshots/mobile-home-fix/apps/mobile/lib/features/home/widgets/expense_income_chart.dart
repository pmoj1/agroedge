import 'package:agroedge_shared/models/expense.dart';
import 'package:agroedge_shared/models/income-record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';

class _MonthBucket {
  const _MonthBucket({required this.label, required this.expenseTotal, required this.incomeTotal});

  final String label;
  final double expenseTotal;
  final double incomeTotal;
}

String _monthKey(DateTime date) => '${date.year}-${date.month}';

double _incomeAmount(IncomeRecord income) {
  if (income.totalRevenue != null) return income.totalRevenue!;
  if (income.pricePerUnit != null && income.quantitySold != null) {
    return income.pricePerUnit! * income.quantitySold!;
  }
  return 0;
}

/// Buckets the last 6 calendar months (including the current one) so the
/// chart shows a short trend rather than a lifetime total -- there is no
/// "season" concept in the data model to scope this to, so months is the
/// honest, simplest window.
List<_MonthBucket> _buildBuckets(List<Expense> expenses, List<IncomeRecord> incomeRecords, DateTime now) {
  final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i)));

  final expenseTotals = <String, double>{};
  for (final expense in expenses) {
    final key = _monthKey(expense.expenseDate);
    expenseTotals[key] = (expenseTotals[key] ?? 0) + expense.amount;
  }

  final incomeTotals = <String, double>{};
  for (final income in incomeRecords) {
    final key = _monthKey(income.incomeDate);
    incomeTotals[key] = (incomeTotals[key] ?? 0) + _incomeAmount(income);
  }

  return months
      .map(
        (month) => _MonthBucket(
          label: DateFormat.MMM().format(month),
          expenseTotal: expenseTotals[_monthKey(month)] ?? 0,
          incomeTotal: incomeTotals[_monthKey(month)] ?? 0,
        ),
      )
      .toList();
}

/// Home's "expenses vs income" glance chart -- grouped bars per month so a
/// farmer can see at a glance whether they're spending more than they're
/// earning. Shows an empty state instead of an all-zero chart when there's
/// no data yet.
class ExpenseIncomeChart extends StatelessWidget {
  const ExpenseIncomeChart({super.key, required this.expenses, required this.incomeRecords, required this.now});

  final List<Expense> expenses;
  final List<IncomeRecord> incomeRecords;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buckets = _buildBuckets(expenses, incomeRecords, now);
    final hasAnyValue = buckets.any((bucket) => bucket.expenseTotal > 0 || bucket.incomeTotal > 0);

    if (!hasAnyValue) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(l10n.homeFinanceChartEmpty, style: const TextStyle(color: AppColors.ink500)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 160,
          child: CustomPaint(painter: _ExpenseIncomeChartPainter(buckets: buckets)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final bucket in buckets)
              Text(bucket.label, style: const TextStyle(fontSize: AppFontSizes.caption, color: AppColors.ink500)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _LegendSwatch(color: AppColors.ink900, label: l10n.homeFinanceChartExpenseLabel),
            const SizedBox(width: AppSpacing.lg),
            _LegendSwatch(color: AppColors.forest700, label: l10n.homeFinanceChartIncomeLabel),
          ],
        ),
      ],
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500)),
      ],
    );
  }
}

class _ExpenseIncomeChartPainter extends CustomPainter {
  const _ExpenseIncomeChartPainter({required this.buckets});

  final List<_MonthBucket> buckets;

  @override
  void paint(Canvas canvas, Size size) {
    if (buckets.isEmpty) return;

    final maxValue = buckets
        .expand((bucket) => [bucket.expenseTotal, bucket.incomeTotal])
        .fold<double>(0, (max, value) => value > max ? value : max);
    if (maxValue <= 0) return;

    final groupWidth = size.width / buckets.length;
    final barWidth = groupWidth * 0.28;
    final gap = groupWidth * 0.08;

    final expensePaint = Paint()..color = AppColors.ink900;
    final incomePaint = Paint()..color = AppColors.forest700;

    for (var i = 0; i < buckets.length; i++) {
      final bucket = buckets[i];
      final centre = groupWidth * i + groupWidth / 2;

      final expenseHeight = (bucket.expenseTotal / maxValue) * size.height;
      final incomeHeight = (bucket.incomeTotal / maxValue) * size.height;

      canvas.drawRect(
        Rect.fromLTWH(centre - gap / 2 - barWidth, size.height - expenseHeight, barWidth, expenseHeight),
        expensePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(centre + gap / 2, size.height - incomeHeight, barWidth, incomeHeight),
        incomePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ExpenseIncomeChartPainter oldDelegate) => true;
}

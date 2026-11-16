import 'package:agroedge_shared/models/activity.dart';
import 'package:agroedge_shared/models/expense.dart';
import 'package:agroedge_shared/models/income-record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';

/// A single chronological feed merging activities, expenses, and income
/// records -- one "what happened on this farm recently" list instead of
/// three separate ones.
class HomeActivityFeed extends StatelessWidget {
  const HomeActivityFeed({
    super.key,
    required this.activities,
    required this.expenses,
    required this.incomeRecords,
    this.maxItems = 8,
  });

  final List<Activity> activities;
  final List<Expense> expenses;
  final List<IncomeRecord> incomeRecords;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd();
    final numberFormat = NumberFormat.decimalPattern();

    final entries = <_FeedEntry>[
      for (final activity in activities)
        _FeedEntry(
          icon: Icons.add_task,
          date: activity.activityDate,
          title: activity.activityType,
          subtitle: l10n.activityListItemSubtitle(activity.crop ?? '—', dateFormat.format(activity.activityDate)),
          amountText: null,
        ),
      for (final expense in expenses)
        _FeedEntry(
          icon: Icons.payments_outlined,
          date: expense.expenseDate,
          title: l10n.homeFeedExpenseTitle,
          subtitle: l10n.homeFeedExpenseSubtitle(expense.category ?? '—', dateFormat.format(expense.expenseDate)),
          amountText: '-${numberFormat.format(expense.amount)}',
        ),
      for (final income in incomeRecords)
        _FeedEntry(
          icon: Icons.attach_money,
          date: income.incomeDate,
          title: l10n.homeFeedIncomeTitle,
          subtitle: l10n.homeFeedIncomeSubtitle(income.crop ?? '—', dateFormat.format(income.incomeDate)),
          amountText: _incomeAmount(income) == null ? null : '+${numberFormat.format(_incomeAmount(income))}',
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final visible = entries.take(maxItems).toList();

    if (visible.isEmpty) {
      return Text(l10n.homeFeedEmpty, style: const TextStyle(color: AppColors.ink500));
    }

    return Column(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const Divider(height: AppSpacing.lg),
          _FeedRow(entry: visible[i]),
        ],
      ],
    );
  }

  static double? _incomeAmount(IncomeRecord income) {
    if (income.totalRevenue != null) return income.totalRevenue;
    if (income.pricePerUnit != null && income.quantitySold != null) {
      return income.pricePerUnit! * income.quantitySold!;
    }
    return null;
  }
}

class _FeedEntry {
  const _FeedEntry({required this.icon, required this.date, required this.title, required this.subtitle, required this.amountText});

  final IconData icon;
  final DateTime date;
  final String title;
  final String subtitle;
  final String? amountText;
}

class _FeedRow extends StatelessWidget {
  const _FeedRow({required this.entry});

  final _FeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.cream100, borderRadius: BorderRadius.circular(AppSpacing.sm)),
            child: Icon(entry.icon, color: AppColors.forest700, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(fontSize: AppFontSizes.body, fontWeight: FontWeight.w600, color: AppColors.ink900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(entry.subtitle, style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500)),
              ],
            ),
          ),
          if (entry.amountText != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              entry.amountText!,
              style: const TextStyle(fontSize: AppFontSizes.body, fontWeight: FontWeight.w600, color: AppColors.ink900),
            ),
          ],
        ],
      ),
    );
  }
}

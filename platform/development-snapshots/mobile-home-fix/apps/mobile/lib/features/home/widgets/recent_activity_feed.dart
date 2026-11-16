import 'package:agroedge_shared/models/activity.dart';
import 'package:agroedge_shared/models/expense.dart';
import 'package:agroedge_shared/models/income-record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';

/// The three record types Home merges into one feed, fetched together so
/// they can be sorted by date as a single list.
class RecentActivityData {
  const RecentActivityData({
    required this.activities,
    required this.expenses,
    required this.incomeRecords,
  });

  final List<Activity> activities;
  final List<Expense> expenses;
  final List<IncomeRecord> incomeRecords;

  bool get isEmpty => activities.isEmpty && expenses.isEmpty && incomeRecords.isEmpty;
}

enum _EntryKind { activity, expense, income }

class _FeedEntry {
  _FeedEntry.activity(Activity value)
      : kind = _EntryKind.activity,
        date = value.activityDate,
        activity = value,
        expense = null,
        income = null;

  _FeedEntry.expense(Expense value)
      : kind = _EntryKind.expense,
        date = value.expenseDate,
        activity = null,
        expense = value,
        income = null;

  _FeedEntry.income(IncomeRecord value)
      : kind = _EntryKind.income,
        date = value.incomeDate,
        activity = null,
        expense = null,
        income = value;

  final _EntryKind kind;
  final DateTime date;
  final Activity? activity;
  final Expense? expense;
  final IncomeRecord? income;
}

List<_FeedEntry> _mergeEntries(RecentActivityData data) {
  final entries = [
    ...data.activities.map(_FeedEntry.activity),
    ...data.expenses.map(_FeedEntry.expense),
    ...data.incomeRecords.map(_FeedEntry.income),
  ];
  entries.sort((a, b) => b.date.compareTo(a.date));
  return entries;
}

String _formatAmount(double? amount) =>
    amount == null ? '—' : NumberFormat('#,##0.00').format(amount);

double? _incomeAmount(IncomeRecord income) {
  if (income.totalRevenue != null) return income.totalRevenue;
  if (income.pricePerUnit != null && income.quantitySold != null) {
    return income.pricePerUnit! * income.quantitySold!;
  }
  return null;
}

/// Home's merged "Recent activity" feed -- activities, expenses and income
/// records sorted together by date, each tagged with an icon and a
/// kind-prefixed title so they stay distinguishable in one list.
class RecentActivityFeed extends StatelessWidget {
  const RecentActivityFeed({super.key, required this.data});

  final RecentActivityData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(l10n.homeNoActivitiesYet, style: const TextStyle(color: AppColors.ink500)),
      );
    }

    return Column(
      children: _mergeEntries(data).map((entry) => _RecentActivityTile(entry: entry)).toList(),
    );
  }
}

class _RecentActivityTile extends StatelessWidget {
  const _RecentActivityTile({required this.entry});

  final _FeedEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateLabel = DateFormat.yMMMd().format(entry.date);

    final IconData icon;
    final String title;
    final String subtitle;

    switch (entry.kind) {
      case _EntryKind.activity:
        final activity = entry.activity!;
        icon = Icons.add_task;
        title = l10n.recentActivityActivityTitle(activity.activityType);
        subtitle = l10n.activityListItemSubtitle(activity.crop ?? '—', dateLabel);
      case _EntryKind.expense:
        final expense = entry.expense!;
        icon = Icons.payments_outlined;
        title = l10n.recentActivityExpenseTitle(_formatAmount(expense.amount));
        subtitle = l10n.recentActivityExpenseSubtitle(expense.category ?? '—', dateLabel);
      case _EntryKind.income:
        final income = entry.income!;
        icon = Icons.attach_money;
        title = l10n.recentActivityIncomeTitle(_formatAmount(_incomeAmount(income)));
        subtitle = l10n.recentActivityIncomeSubtitle(income.buyer ?? '—', dateLabel);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: AppColors.forest700),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

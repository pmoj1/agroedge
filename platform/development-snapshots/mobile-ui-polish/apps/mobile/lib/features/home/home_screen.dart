import 'package:agroedge_shared/models/activity.dart';
import 'package:agroedge_shared/models/ai-crop-plan.dart';
import 'package:agroedge_shared/models/ai-insight.dart';
import 'package:agroedge_shared/models/expense.dart';
import 'package:agroedge_shared/models/farm-profile.dart';
import 'package:agroedge_shared/models/income-record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_services.dart';
import '../../core/page_transitions.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../log_activity/log_activity_screen.dart';
import '../log_expense/log_expense_screen.dart';
import '../log_income/log_income_screen.dart';
import 'widgets/home_activity_chart.dart';
import 'widgets/home_activity_feed.dart';
import 'widgets/home_header.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/home_section_card.dart';
import 'widgets/home_skeleton.dart';
import 'widgets/home_stats_row.dart';

/// Home: brand header with the farmer's name and farm, a stats-at-a-glance
/// row, quick-action cards to log activity/expense/income or ask the AI,
/// and a merged recent-activity feed + trend chart.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.farmProfile});

  /// Passed down from AuthGate, which already fetched it to decide
  /// whether to route here -- avoids a second network round trip just to
  /// show the farm name in the header.
  final FarmProfile farmProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<_HomeDashboardData> _loadDashboard() async {
    final services = AppServices.instance;
    final results = await Future.wait([
      services.activities.list(),
      services.expenses.list(),
      services.incomeRecords.list(),
      services.aiCropPlans.list(),
      services.aiInsights.list(),
    ]);
    return _HomeDashboardData(
      activities: results[0] as List<Activity>,
      expenses: results[1] as List<Expense>,
      incomeRecords: results[2] as List<IncomeRecord>,
      cropPlans: results[3] as List<AiCropPlan>,
      insights: results[4] as List<AiInsight>,
    );
  }

  void _refresh() {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.of(context).push(fadeThroughRoute(screen));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.cream100,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            HomeHeader(
              greetingName: displayNameFromEmail(Supabase.instance.client.auth.currentUser?.email),
              farmName: widget.farmProfile.farmName,
              today: today,
              onSignOut: () => Supabase.instance.client.auth.signOut(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: FutureBuilder<_HomeDashboardData>(
                  future: _dashboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const HomeSkeleton();
                    }
                    if (snapshot.hasError) {
                      return _HomeError(onRetry: _refresh);
                    }
                    return _HomeContent(
                      data: snapshot.data!,
                      onLogActivity: () => _openScreen(const LogActivityScreen()),
                      onLogExpense: () => _openScreen(const LogExpenseScreen()),
                      onLogIncome: () => _openScreen(const LogIncomeScreen()),
                      onAskAi: () => _openScreen(const AiChatScreen()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboardData {
  const _HomeDashboardData({
    required this.activities,
    required this.expenses,
    required this.incomeRecords,
    required this.cropPlans,
    required this.insights,
  });

  final List<Activity> activities;
  final List<Expense> expenses;
  final List<IncomeRecord> incomeRecords;
  final List<AiCropPlan> cropPlans;
  final List<AiInsight> insights;
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Text(l10n.commonSomethingWentWrong, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Center(child: ElevatedButton(onPressed: onRetry, child: Text(l10n.commonRetry))),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.onLogActivity,
    required this.onLogExpense,
    required this.onLogIncome,
    required this.onAskAi,
  });

  final _HomeDashboardData data;
  final VoidCallback onLogActivity;
  final VoidCallback onLogExpense;
  final VoidCallback onLogIncome;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat.decimalPattern();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    bool isThisMonth(DateTime date) => !date.isBefore(monthStart);

    final activitiesThisMonth = data.activities.where((a) => isThisMonth(a.activityDate)).length;
    final expensesThisMonth =
        data.expenses.where((e) => isThisMonth(e.expenseDate)).fold<double>(0, (sum, e) => sum + e.amount);
    final incomeThisMonth = data.incomeRecords.where((i) => isThisMonth(i.incomeDate)).fold<double>(0, (sum, i) {
      final revenue =
          i.totalRevenue ?? ((i.pricePerUnit != null && i.quantitySold != null) ? i.pricePerUnit! * i.quantitySold! : 0);
      return sum + revenue;
    });

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        HomeStatsRow(
          stats: [
            HomeStat(icon: Icons.add_task, value: '$activitiesThisMonth', label: l10n.homeStatActivities),
            HomeStat(icon: Icons.payments_outlined, value: numberFormat.format(expensesThisMonth), label: l10n.homeStatExpenses),
            HomeStat(icon: Icons.attach_money, value: numberFormat.format(incomeThisMonth), label: l10n.homeStatIncome),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.homeQuickActionsHeading,
          style: const TextStyle(fontSize: AppFontSizes.subtitle, fontWeight: FontWeight.w600, color: AppColors.ink900),
        ),
        const SizedBox(height: AppSpacing.md),
        HomeQuickActions(
          actions: [
            HomeQuickAction(icon: Icons.add_task, label: l10n.homeLogActivity, onPressed: onLogActivity),
            HomeQuickAction(icon: Icons.payments_outlined, label: l10n.homeLogExpense, onPressed: onLogExpense),
            HomeQuickAction(icon: Icons.attach_money, label: l10n.homeLogIncome, onPressed: onLogIncome),
            HomeQuickAction(icon: Icons.chat_bubble_outline, label: l10n.homeAskAi, onPressed: onAskAi),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        HomeSectionCard(
          title: l10n.homeRecentActivities,
          child: HomeActivityFeed(
            activities: data.activities,
            expenses: data.expenses,
            incomeRecords: data.incomeRecords,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        HomeSectionCard(
          title: l10n.homeTrendHeading,
          subtitle: l10n.homeTrendSubtitle,
          child: HomeActivityChart(activities: data.activities),
        ),
        const SizedBox(height: AppSpacing.lg),
        HomeSectionCard(
          title: l10n.homeAiInsightsHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.homeCropPlanHeading, style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500)),
              const SizedBox(height: AppSpacing.sm),
              if (data.cropPlans.isEmpty)
                Text(l10n.homeCropPlanEmpty, style: const TextStyle(color: AppColors.ink500))
              else
                _CropPlanSummary(plan: data.cropPlans.first),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.homeInsightsHeading, style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500)),
              const SizedBox(height: AppSpacing.sm),
              if (data.insights.isEmpty)
                Text(l10n.homeInsightsEmpty, style: const TextStyle(color: AppColors.ink500))
              else
                Column(
                  children: [
                    for (var i = 0; i < data.insights.length; i++) ...[
                      if (i > 0) const Divider(height: AppSpacing.lg),
                      _InsightRow(insight: data.insights[i]),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CropPlanSummary extends StatelessWidget {
  const _CropPlanSummary({required this.plan});

  final AiCropPlan plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plan.priorityAction != null)
          Text(plan.priorityAction!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink900)),
        if (plan.priorityAction != null && plan.recommendationText != null) const SizedBox(height: AppSpacing.sm),
        if (plan.recommendationText != null)
          Text(plan.recommendationText!, style: const TextStyle(color: AppColors.ink900)),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});

  final AiInsight insight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(insight.category ?? '—', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink900)),
        const SizedBox(height: AppSpacing.xs),
        Text(insight.insightText ?? '', style: const TextStyle(color: AppColors.ink900)),
      ],
    );
  }
}

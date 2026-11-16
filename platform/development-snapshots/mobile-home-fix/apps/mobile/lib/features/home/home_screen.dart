import 'package:agroedge_shared/models/ai-crop-plan.dart';
import 'package:agroedge_shared/models/ai-insight.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_services.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../log_activity/log_activity_screen.dart';
import '../log_expense/log_expense_screen.dart';
import '../log_income/log_income_screen.dart';
import 'widgets/expense_income_chart.dart';
import 'widgets/recent_activity_feed.dart';

/// Home: today's date, shortcuts to log an activity/expense/income and to
/// open the AI chat, and a simple list of recent activities -- per the
/// build brief.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<RecentActivityData> _recentActivityFuture;
  late Future<List<AiCropPlan>> _cropPlansFuture;
  late Future<List<AiInsight>> _insightsFuture;

  @override
  void initState() {
    super.initState();
    _recentActivityFuture = _loadRecentActivity();
    _cropPlansFuture = AppServices.instance.aiCropPlans.list();
    _insightsFuture = AppServices.instance.aiInsights.list();
  }

  Future<RecentActivityData> _loadRecentActivity() async {
    final activitiesFuture = AppServices.instance.activities.list();
    final expensesFuture = AppServices.instance.expenses.list();
    final incomeFuture = AppServices.instance.incomeRecords.list();
    return RecentActivityData(
      activities: await activitiesFuture,
      expenses: await expensesFuture,
      incomeRecords: await incomeFuture,
    );
  }

  void _refreshActivities() {
    setState(() {
      _recentActivityFuture = _loadRecentActivity();
    });
  }

  void _refreshAiInsights() {
    setState(() {
      _cropPlansFuture = AppServices.instance.aiCropPlans.list();
      _insightsFuture = AppServices.instance.aiInsights.list();
    });
  }

  Future<void> _refreshAll() async {
    _refreshActivities();
    _refreshAiInsights();
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _refreshActivities();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonSignOut,
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                today,
                style: const TextStyle(fontSize: AppFontSizes.subtitle, color: AppColors.ink500),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _ShortcutButton(
                    icon: Icons.add_task,
                    label: l10n.homeLogActivity,
                    onPressed: () => _openScreen(const LogActivityScreen()),
                  ),
                  _ShortcutButton(
                    icon: Icons.payments_outlined,
                    label: l10n.homeLogExpense,
                    onPressed: () => _openScreen(const LogExpenseScreen()),
                  ),
                  _ShortcutButton(
                    icon: Icons.attach_money,
                    label: l10n.homeLogIncome,
                    onPressed: () => _openScreen(const LogIncomeScreen()),
                  ),
                  _ShortcutButton(
                    icon: Icons.chat_bubble_outline,
                    label: l10n.homeAskAi,
                    onPressed: () => _openScreen(const AiChatScreen()),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.homeRecentActivities,
                style: const TextStyle(fontSize: AppFontSizes.subtitle, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.md),
              FutureBuilder<RecentActivityData>(
                future: _recentActivityFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Column(
                        children: [
                          Text(l10n.commonSomethingWentWrong),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton(onPressed: _refreshActivities, child: Text(l10n.commonRetry)),
                        ],
                      ),
                    );
                  }
                  return RecentActivityFeed(
                    data: snapshot.data ??
                        const RecentActivityData(activities: [], expenses: [], incomeRecords: []),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.homeFinanceChartHeading,
                style: const TextStyle(fontSize: AppFontSizes.subtitle, fontWeight: FontWeight.w600),
              ),
              Text(
                l10n.homeFinanceChartSubheading,
                style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500),
              ),
              const SizedBox(height: AppSpacing.md),
              FutureBuilder<RecentActivityData>(
                future: _recentActivityFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text(l10n.commonSomethingWentWrong),
                    );
                  }
                  final data = snapshot.data ??
                      const RecentActivityData(activities: [], expenses: [], incomeRecords: []);
                  return ExpenseIncomeChart(
                    expenses: data.expenses,
                    incomeRecords: data.incomeRecords,
                    now: DateTime.now(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.homeAiInsightsHeading,
                style: const TextStyle(fontSize: AppFontSizes.subtitle, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.homeCropPlanHeading,
                style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500),
              ),
              const SizedBox(height: AppSpacing.sm),
              FutureBuilder<List<AiCropPlan>>(
                future: _cropPlansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Column(
                        children: [
                          Text(l10n.commonSomethingWentWrong),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton(onPressed: _refreshAiInsights, child: Text(l10n.commonRetry)),
                        ],
                      ),
                    );
                  }
                  final cropPlans = snapshot.data ?? const [];
                  if (cropPlans.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(l10n.homeCropPlanEmpty, style: const TextStyle(color: AppColors.ink500)),
                    );
                  }
                  final currentPlan = cropPlans.first;
                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentPlan.priorityAction != null)
                            Text(
                              currentPlan.priorityAction!,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          if (currentPlan.priorityAction != null && currentPlan.recommendationText != null)
                            const SizedBox(height: AppSpacing.sm),
                          if (currentPlan.recommendationText != null)
                            Text(currentPlan.recommendationText!),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.homeInsightsHeading,
                style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.ink500),
              ),
              const SizedBox(height: AppSpacing.sm),
              FutureBuilder<List<AiInsight>>(
                future: _insightsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Column(
                        children: [
                          Text(l10n.commonSomethingWentWrong),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton(onPressed: _refreshAiInsights, child: Text(l10n.commonRetry)),
                        ],
                      ),
                    );
                  }
                  final insights = snapshot.data ?? const [];
                  if (insights.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(l10n.homeInsightsEmpty, style: const TextStyle(color: AppColors.ink500)),
                    );
                  }
                  return Column(
                    children: insights
                        .map(
                          (insight) => Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              title: Text(insight.category ?? '—'),
                              subtitle: Text(insight.insightText ?? ''),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

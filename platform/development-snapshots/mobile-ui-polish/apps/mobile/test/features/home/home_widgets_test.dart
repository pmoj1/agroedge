import 'package:agroedge_shared/models/activity.dart';
import 'package:agroedge_shared/models/expense.dart';
import 'package:agroedge_shared/models/income-record.dart';
import 'package:agroedge_mobile/core/theme.dart';
import 'package:agroedge_mobile/features/home/widgets/home_activity_chart.dart';
import 'package:agroedge_mobile/features/home/widgets/home_activity_feed.dart';
import 'package:agroedge_mobile/features/home/widgets/home_header.dart';
import 'package:agroedge_mobile/features/home/widgets/home_quick_actions.dart';
import 'package:agroedge_mobile/features/home/widgets/home_section_card.dart';
import 'package:agroedge_mobile/features/home/widgets/home_stats_row.dart';
import 'package:agroedge_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the redesigned Home screen's pieces together, at a small
/// low-end-Android viewport, with non-empty realistic data (one activity,
/// one expense, one income record) -- the scenario the build brief calls
/// out specifically ("check this by actually looking at it with the
/// activity/expense you already logged, not just empty states"). Catches
/// RenderFlex overflow and other layout exceptions that `flutter analyze`
/// cannot see.
void main() {
  testWidgets('Home content renders without overflow on a small phone with real data', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final activity = Activity(activityType: 'Planting', crop: 'Maize', activityDate: DateTime(2026, 7, 3));
    final expense = Expense(amount: 450.50, category: 'Fertiliser', expenseDate: DateTime(2026, 7, 5));
    final income = IncomeRecord(incomeDate: DateTime(2026, 7, 8), crop: 'Maize', totalRevenue: 1200);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          backgroundColor: AppColors.cream100,
          body: SafeArea(
            child: Column(
              children: [
                HomeHeader(
                  greetingName: 'Thabo',
                  farmName: 'Thabo Family Farm',
                  today: 'July 10, 2026',
                  onSignOut: () {},
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      HomeStatsRow(
                        stats: [
                          HomeStat(icon: Icons.add_task, value: '4', label: 'Activities this month'),
                          HomeStat(icon: Icons.payments_outlined, value: '450.5', label: 'Expenses this month'),
                          HomeStat(icon: Icons.attach_money, value: '1,200', label: 'Income this month'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      HomeQuickActions(
                        actions: [
                          HomeQuickAction(icon: Icons.add_task, label: 'Log activity', onPressed: () {}),
                          HomeQuickAction(icon: Icons.payments_outlined, label: 'Log expense', onPressed: () {}),
                          HomeQuickAction(icon: Icons.attach_money, label: 'Log income', onPressed: () {}),
                          HomeQuickAction(icon: Icons.chat_bubble_outline, label: 'Ask the AI agronomist', onPressed: () {}),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      HomeSectionCard(
                        title: 'Recent activity',
                        child: HomeActivityFeed(activities: [activity], expenses: [expense], incomeRecords: [income]),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      HomeSectionCard(
                        title: 'Activity trend',
                        subtitle: 'Activities logged per week, last 4 weeks',
                        child: HomeActivityChart(activities: [activity]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Recent activity'), findsOneWidget);

    // Scroll to the bottom of the dashboard to exercise the rest of the
    // layout too (the chart card is below the fold at this viewport size).
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Activity trend'), findsOneWidget);

    if (errors.isNotEmpty) {
      for (final error in errors) {
        debugPrint(error.toString());
      }
    }
    expect(errors, isEmpty, reason: 'See printed FlutterError diagnostics above.');
  });
}

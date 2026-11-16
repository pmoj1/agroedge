import '../data/activity_repository.dart';
import '../data/ai_crop_plan_repository.dart';
import '../data/ai_insight_repository.dart';
import '../data/expense_repository.dart';
import '../data/farm_profile_repository.dart';
import '../data/income_repository.dart';
import 'api_client.dart';

/// Single set of long-lived service instances for this pilot build. A
/// full DI setup (Provider/Riverpod) is unnecessary for 3 screens and 3
/// pilot users -- see the "keep each one simple" scope in the build brief.
class AppServices {
  factory AppServices() => instance;

  AppServices._internal()
    : apiClient = ApiClient(),
      farmProfiles = FarmProfileRepository(_sharedClient),
      activities = ActivityRepository(_sharedClient),
      expenses = ExpenseRepository(_sharedClient),
      incomeRecords = IncomeRepository(_sharedClient),
      aiCropPlans = AiCropPlanRepository(_sharedClient),
      aiInsights = AiInsightRepository(_sharedClient);

  static final ApiClient _sharedClient = ApiClient();
  static final AppServices instance = AppServices._internal();

  final ApiClient apiClient;
  final FarmProfileRepository farmProfiles;
  final ActivityRepository activities;
  final ExpenseRepository expenses;
  final IncomeRepository incomeRecords;
  final AiCropPlanRepository aiCropPlans;
  final AiInsightRepository aiInsights;
}

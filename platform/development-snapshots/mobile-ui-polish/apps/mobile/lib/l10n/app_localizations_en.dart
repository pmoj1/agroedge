// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgroEdge';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get signInTitle => 'Sign in to AgroEdge';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signInInvalidCredentials => 'Incorrect email or password.';

  @override
  String get signInGenericError => 'Could not sign in. Please try again.';

  @override
  String get farmSetupTitle => 'Set up your farm';

  @override
  String get farmSetupIntro =>
      'Tell us a bit about your farm. You only need to do this once.';

  @override
  String get farmSetupFarmNameLabel => 'Farm name';

  @override
  String get farmSetupFarmSizeLabel => 'Farm size (hectares)';

  @override
  String get farmSetupPrimaryCropLabel => 'Primary crop';

  @override
  String get farmSetupRegionLabel => 'Region';

  @override
  String get farmSetupSaveButton => 'Save and continue';

  @override
  String get farmSetupRequiredField => 'This field is required';

  @override
  String get homeLogActivity => 'Log activity';

  @override
  String get homeAskAi => 'Ask the AI agronomist';

  @override
  String get homeRecentActivities => 'Recent activity';

  @override
  String get homeNoActivitiesYet => 'No activities logged yet.';

  @override
  String get homeLogExpense => 'Log expense';

  @override
  String get homeLogIncome => 'Log income';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeQuickActionsHeading => 'Quick actions';

  @override
  String get homeStatActivities => 'Activities this month';

  @override
  String get homeStatExpenses => 'Expenses this month';

  @override
  String get homeStatIncome => 'Income this month';

  @override
  String get homeFeedEmpty =>
      'Nothing logged yet. Log your first activity, expense, or income to see it here.';

  @override
  String get homeFeedExpenseTitle => 'Expense';

  @override
  String get homeFeedIncomeTitle => 'Income';

  @override
  String homeFeedExpenseSubtitle(String category, String date) {
    return '$category — $date';
  }

  @override
  String homeFeedIncomeSubtitle(String crop, String date) {
    return '$crop — $date';
  }

  @override
  String get homeTrendHeading => 'Activity trend';

  @override
  String get homeTrendSubtitle => 'Activities logged per week, last 4 weeks';

  @override
  String get homeTrendEmpty => 'Log a few activities to see your trend here.';

  @override
  String homeTrendWeekSemanticLabel(String date, int count) {
    return 'Week of $date: $count activities';
  }

  @override
  String get homeAiInsightsHeading => 'AI insights';

  @override
  String get homeCropPlanHeading => 'Current crop plan';

  @override
  String get homeCropPlanEmpty => 'No crop plan yet.';

  @override
  String get homeInsightsHeading => 'Recent insights';

  @override
  String get homeInsightsEmpty => 'No insights yet.';

  @override
  String activityListItemSubtitle(String crop, String date) {
    return '$crop — $date';
  }

  @override
  String get logActivityTitle => 'Log activity';

  @override
  String get logActivityTypeLabel => 'Activity type';

  @override
  String get logActivityCropLabel => 'Crop';

  @override
  String get logActivityDateLabel => 'Date';

  @override
  String get logActivityNotesLabel => 'Notes';

  @override
  String get logActivityYieldQuantityLabel => 'Yield quantity';

  @override
  String get logActivityYieldUnitLabel => 'Yield unit';

  @override
  String get logActivitySavedConfirmation => 'Activity logged.';

  @override
  String get logExpenseTitle => 'Log expense';

  @override
  String get logExpenseAmountLabel => 'Amount';

  @override
  String get logExpenseCategoryLabel => 'Category';

  @override
  String get logExpenseDateLabel => 'Date';

  @override
  String get logExpenseNotesLabel => 'Notes';

  @override
  String get logExpenseSavedConfirmation => 'Expense logged.';

  @override
  String get logIncomeTitle => 'Log income';

  @override
  String get logIncomeCropLabel => 'Crop';

  @override
  String get logIncomeBuyerLabel => 'Buyer';

  @override
  String get logIncomeDateLabel => 'Date';

  @override
  String get logIncomePricePerUnitLabel => 'Price per unit';

  @override
  String get logIncomeQuantitySoldLabel => 'Quantity sold';

  @override
  String get logIncomeTotalRevenueLabel => 'Total revenue';

  @override
  String get logIncomeSavedConfirmation => 'Income logged.';

  @override
  String get aiChatTitle => 'AI agronomist';

  @override
  String get aiChatComingSoonTitle => 'Coming soon';

  @override
  String get aiChatComingSoonBody =>
      'The AI agronomist chat is not connected yet. This screen will let you ask questions about your farm once it\'s ready.';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationMustBeNumber => 'Must be a number';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App title shown in the browser tab and app bar.
  ///
  /// In en, this message translates to:
  /// **'AgroEdge'**
  String get appTitle;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrong;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to AgroEdge'**
  String get signInTitle;

  /// No description provided for @signInEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signInEmailLabel;

  /// No description provided for @signInPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signInPasswordLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signInInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get signInInvalidCredentials;

  /// No description provided for @signInGenericError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please try again.'**
  String get signInGenericError;

  /// No description provided for @farmSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your farm'**
  String get farmSetupTitle;

  /// No description provided for @farmSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about your farm. You only need to do this once.'**
  String get farmSetupIntro;

  /// No description provided for @farmSetupFarmNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm name'**
  String get farmSetupFarmNameLabel;

  /// No description provided for @farmSetupFarmSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm size (hectares)'**
  String get farmSetupFarmSizeLabel;

  /// No description provided for @farmSetupPrimaryCropLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary crop'**
  String get farmSetupPrimaryCropLabel;

  /// No description provided for @farmSetupRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get farmSetupRegionLabel;

  /// No description provided for @farmSetupSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get farmSetupSaveButton;

  /// No description provided for @farmSetupRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get farmSetupRequiredField;

  /// No description provided for @homeLogActivity.
  ///
  /// In en, this message translates to:
  /// **'Log activity'**
  String get homeLogActivity;

  /// No description provided for @homeAskAi.
  ///
  /// In en, this message translates to:
  /// **'Ask the AI agronomist'**
  String get homeAskAi;

  /// No description provided for @homeRecentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get homeRecentActivities;

  /// No description provided for @homeNoActivitiesYet.
  ///
  /// In en, this message translates to:
  /// **'No activities logged yet.'**
  String get homeNoActivitiesYet;

  /// No description provided for @homeLogExpense.
  ///
  /// In en, this message translates to:
  /// **'Log expense'**
  String get homeLogExpense;

  /// No description provided for @homeLogIncome.
  ///
  /// In en, this message translates to:
  /// **'Log income'**
  String get homeLogIncome;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeQuickActionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActionsHeading;

  /// No description provided for @homeStatActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities this month'**
  String get homeStatActivities;

  /// No description provided for @homeStatExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses this month'**
  String get homeStatExpenses;

  /// No description provided for @homeStatIncome.
  ///
  /// In en, this message translates to:
  /// **'Income this month'**
  String get homeStatIncome;

  /// No description provided for @homeFeedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Log your first activity, expense, or income to see it here.'**
  String get homeFeedEmpty;

  /// No description provided for @homeFeedExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get homeFeedExpenseTitle;

  /// No description provided for @homeFeedIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get homeFeedIncomeTitle;

  /// No description provided for @homeFeedExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{category} — {date}'**
  String homeFeedExpenseSubtitle(String category, String date);

  /// No description provided for @homeFeedIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{crop} — {date}'**
  String homeFeedIncomeSubtitle(String crop, String date);

  /// No description provided for @homeTrendHeading.
  ///
  /// In en, this message translates to:
  /// **'Activity trend'**
  String get homeTrendHeading;

  /// No description provided for @homeTrendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Activities logged per week, last 4 weeks'**
  String get homeTrendSubtitle;

  /// No description provided for @homeTrendEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log a few activities to see your trend here.'**
  String get homeTrendEmpty;

  /// No description provided for @homeTrendWeekSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}: {count} activities'**
  String homeTrendWeekSemanticLabel(String date, int count);

  /// No description provided for @homeAiInsightsHeading.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get homeAiInsightsHeading;

  /// No description provided for @homeCropPlanHeading.
  ///
  /// In en, this message translates to:
  /// **'Current crop plan'**
  String get homeCropPlanHeading;

  /// No description provided for @homeCropPlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'No crop plan yet.'**
  String get homeCropPlanEmpty;

  /// No description provided for @homeInsightsHeading.
  ///
  /// In en, this message translates to:
  /// **'Recent insights'**
  String get homeInsightsHeading;

  /// No description provided for @homeInsightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No insights yet.'**
  String get homeInsightsEmpty;

  /// No description provided for @activityListItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{crop} — {date}'**
  String activityListItemSubtitle(String crop, String date);

  /// No description provided for @logActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Log activity'**
  String get logActivityTitle;

  /// No description provided for @logActivityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get logActivityTypeLabel;

  /// No description provided for @logActivityCropLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get logActivityCropLabel;

  /// No description provided for @logActivityDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get logActivityDateLabel;

  /// No description provided for @logActivityNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get logActivityNotesLabel;

  /// No description provided for @logActivityYieldQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Yield quantity'**
  String get logActivityYieldQuantityLabel;

  /// No description provided for @logActivityYieldUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Yield unit'**
  String get logActivityYieldUnitLabel;

  /// No description provided for @logActivitySavedConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Activity logged.'**
  String get logActivitySavedConfirmation;

  /// No description provided for @logExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Log expense'**
  String get logExpenseTitle;

  /// No description provided for @logExpenseAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get logExpenseAmountLabel;

  /// No description provided for @logExpenseCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get logExpenseCategoryLabel;

  /// No description provided for @logExpenseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get logExpenseDateLabel;

  /// No description provided for @logExpenseNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get logExpenseNotesLabel;

  /// No description provided for @logExpenseSavedConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Expense logged.'**
  String get logExpenseSavedConfirmation;

  /// No description provided for @logIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Log income'**
  String get logIncomeTitle;

  /// No description provided for @logIncomeCropLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get logIncomeCropLabel;

  /// No description provided for @logIncomeBuyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get logIncomeBuyerLabel;

  /// No description provided for @logIncomeDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get logIncomeDateLabel;

  /// No description provided for @logIncomePricePerUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get logIncomePricePerUnitLabel;

  /// No description provided for @logIncomeQuantitySoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity sold'**
  String get logIncomeQuantitySoldLabel;

  /// No description provided for @logIncomeTotalRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get logIncomeTotalRevenueLabel;

  /// No description provided for @logIncomeSavedConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Income logged.'**
  String get logIncomeSavedConfirmation;

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI agronomist'**
  String get aiChatTitle;

  /// No description provided for @aiChatComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get aiChatComingSoonTitle;

  /// No description provided for @aiChatComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'The AI agronomist chat is not connected yet. This screen will let you ask questions about your farm once it\'s ready.'**
  String get aiChatComingSoonBody;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// No description provided for @validationMustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a number'**
  String get validationMustBeNumber;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

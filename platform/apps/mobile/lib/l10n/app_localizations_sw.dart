// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'AgroEdge';

  @override
  String get commonSave => 'Hifadhi';

  @override
  String get commonCancel => 'Ghairi';

  @override
  String get commonSignOut => 'Toka';

  @override
  String get commonRetry => 'Jaribu tena';

  @override
  String get commonOptional => 'Si lazima';

  @override
  String get commonSomethingWentWrong => 'Kuna tatizo. Tafadhali jaribu tena.';

  @override
  String get signInTitle => 'Ingia AgroEdge';

  @override
  String get signInEmailLabel => 'Barua pepe';

  @override
  String get signInPasswordLabel => 'Nywila';

  @override
  String get signInButton => 'Ingia';

  @override
  String get signInInvalidCredentials => 'Barua pepe au nywila si sahihi.';

  @override
  String get signInGenericError => 'Haikuweza kuingia. Tafadhali jaribu tena.';

  @override
  String get farmSetupTitle => 'Weka shamba lako';

  @override
  String get farmSetupIntro =>
      'Tuambie kidogo kuhusu shamba lako. Unahitaji kufanya hivi mara moja tu.';

  @override
  String get farmSetupFarmNameLabel => 'Jina la shamba';

  @override
  String get farmSetupFarmSizeLabel => 'Ukubwa wa shamba (hekta)';

  @override
  String get farmSetupPrimaryCropLabel => 'Mazao ya kwanza';

  @override
  String get farmSetupRegionLabel => 'Mkoa';

  @override
  String get farmSetupSaveButton => 'Hifadhi na endelea';

  @override
  String get farmSetupRequiredField => 'Sehemu hii inahitajika';

  @override
  String get homeLogActivity => 'Rekodi shughuli';

  @override
  String get homeAskAi => 'Uliza mshauri wa AI';

  @override
  String get homeRecentActivities => 'Shughuli za hivi karibuni';

  @override
  String get homeNoActivitiesYet => 'Hakuna shughuli bado.';

  @override
  String get homeLogExpense => 'Rekodi gharama';

  @override
  String get homeLogIncome => 'Rekodi mapato';

  @override
  String get homeAiInsightsHeading => 'Maoni ya AI';

  @override
  String get homeCropPlanHeading => 'Mpango wa mazao';

  @override
  String get homeCropPlanEmpty => 'Hakuna mpango wa mazao bado.';

  @override
  String get homeInsightsHeading => 'Maoni ya hivi karibuni';

  @override
  String get homeInsightsEmpty => 'Hakuna maoni bado.';

  @override
  String activityListItemSubtitle(String crop, String date) {
    return '$crop — $date';
  }

  @override
  String get logActivityTitle => 'Rekodi shughuli';

  @override
  String get logActivityTypeLabel => 'Aina ya shughuli';

  @override
  String get logActivityCropLabel => 'Zao';

  @override
  String get logActivityDateLabel => 'Tarehe';

  @override
  String get logActivityNotesLabel => 'Maelezo';

  @override
  String get logActivityYieldQuantityLabel => 'Kiasi cha mavuno';

  @override
  String get logActivityYieldUnitLabel => 'Kipimo cha mavuno';

  @override
  String get logActivitySavedConfirmation => 'Shughuli imerekidiwa.';

  @override
  String get logExpenseTitle => 'Rekodi gharama';

  @override
  String get logExpenseAmountLabel => 'Kiasi';

  @override
  String get logExpenseCategoryLabel => 'Kategoria';

  @override
  String get logExpenseDateLabel => 'Tarehe';

  @override
  String get logExpenseNotesLabel => 'Maelezo';

  @override
  String get logExpenseSavedConfirmation => 'Gharama imerekidiwa.';

  @override
  String get logIncomeTitle => 'Rekodi mapato';

  @override
  String get logIncomeCropLabel => 'Zao';

  @override
  String get logIncomeBuyerLabel => 'Mnunuzi';

  @override
  String get logIncomeDateLabel => 'Tarehe';

  @override
  String get logIncomePricePerUnitLabel => 'Bei kwa kipimo';

  @override
  String get logIncomeQuantitySoldLabel => 'Kiasi kilichouzwa';

  @override
  String get logIncomeTotalRevenueLabel => 'Mapato yote';

  @override
  String get logIncomeSavedConfirmation => 'Mapato yamerekidiwa.';

  @override
  String get aiChatTitle => 'Mshauri wa AI';

  @override
  String get aiChatComingSoonTitle => 'Inakuja hivi karibuni';

  @override
  String get aiChatComingSoonBody => 'Mshauri wa AI atapatikana hivi karibuni.';

  @override
  String get validationRequired => 'Inahitajika';

  @override
  String get validationMustBeNumber => 'Lazima iwe nambari';
}

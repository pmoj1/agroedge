// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Shona (`sn`).
class AppLocalizationsSn extends AppLocalizations {
  AppLocalizationsSn([String locale = 'sn']) : super(locale);

  @override
  String get appTitle => 'AgroEdge';

  @override
  String get commonSave => 'Chengetedza';

  @override
  String get commonCancel => 'Dzima';

  @override
  String get commonSignOut => 'Buda';

  @override
  String get commonRetry => 'Edza zvakare';

  @override
  String get commonOptional => 'Hazvibatanidzwi';

  @override
  String get commonSomethingWentWrong =>
      'Pane chakakanganisika. Ndapota edza zvakare.';

  @override
  String get signInTitle => 'Pinda mu AgroEdge';

  @override
  String get signInEmailLabel => 'Imeri';

  @override
  String get signInPasswordLabel => 'Pasiwedhi';

  @override
  String get signInButton => 'Pinda';

  @override
  String get signInInvalidCredentials => 'Imeri kana pasiwedhi hazvina kunaka.';

  @override
  String get signInGenericError => 'Hapana. Ndapota edza zvakare.';

  @override
  String get farmSetupTitle => 'Gadzirira purazi rako';

  @override
  String get farmSetupIntro =>
      'Tiudze nezve purazi rako. Unofanira kuita izvi kamwe chete.';

  @override
  String get farmSetupFarmNameLabel => 'Zita repurazi';

  @override
  String get farmSetupFarmSizeLabel => 'Kukura kwepurazi (mahekita)';

  @override
  String get farmSetupPrimaryCropLabel => 'Mbesa yekutanga';

  @override
  String get farmSetupRegionLabel => 'Dunhu';

  @override
  String get farmSetupSaveButton => 'Chengetedza uendelee';

  @override
  String get farmSetupRequiredField => 'Nzvimbo iyi inodiwa';

  @override
  String get homeLogActivity => 'Nyora mabasa';

  @override
  String get homeAskAi => 'Bvunza mudzidzisi weAI';

  @override
  String get homeRecentActivities => 'Mabasa ekupedzisira';

  @override
  String get homeNoActivitiesYet => 'Hapana mabasa akanyorwa.';

  @override
  String get homeLogExpense => 'Nyora chakakosha';

  @override
  String get homeLogIncome => 'Nyora mari yakawana';

  @override
  String get homeAiInsightsHeading => 'Zano reAI';

  @override
  String get homeCropPlanHeading => 'Chirongwa chemhuri';

  @override
  String get homeCropPlanEmpty => 'Hapana chirongwa chemhuri.';

  @override
  String get homeInsightsHeading => 'Mazano ekupedzisira';

  @override
  String get homeInsightsEmpty => 'Hapana mazano.';

  @override
  String activityListItemSubtitle(String crop, String date) {
    return '$crop — $date';
  }

  @override
  String get logActivityTitle => 'Nyora mabasa';

  @override
  String get logActivityTypeLabel => 'Rudzi rwemabasa';

  @override
  String get logActivityCropLabel => 'Mbesa';

  @override
  String get logActivityDateLabel => 'Zuva';

  @override
  String get logActivityNotesLabel => 'Manotsi';

  @override
  String get logActivityYieldQuantityLabel => 'Huwandu hwemhuri';

  @override
  String get logActivityYieldUnitLabel => 'Chiyero chemhuri';

  @override
  String get logActivitySavedConfirmation => 'Mabasa enyorwa.';

  @override
  String get logExpenseTitle => 'Nyora chakakosha';

  @override
  String get logExpenseAmountLabel => 'Huwandu';

  @override
  String get logExpenseCategoryLabel => 'Chikamu';

  @override
  String get logExpenseDateLabel => 'Zuva';

  @override
  String get logExpenseNotesLabel => 'Manotsi';

  @override
  String get logExpenseSavedConfirmation => 'Chakakosha chenyorwa.';

  @override
  String get logIncomeTitle => 'Nyora mari yakawana';

  @override
  String get logIncomeCropLabel => 'Mbesa';

  @override
  String get logIncomeBuyerLabel => 'Mutengi';

  @override
  String get logIncomeDateLabel => 'Zuva';

  @override
  String get logIncomePricePerUnitLabel => 'Mutengo pachiyero';

  @override
  String get logIncomeQuantitySoldLabel => 'Huwandu hwakatengeswa';

  @override
  String get logIncomeTotalRevenueLabel => 'Mari yose yakawana';

  @override
  String get logIncomeSavedConfirmation => 'Mari yakanyorwa.';

  @override
  String get aiChatTitle => 'Mudzidzisi weAI';

  @override
  String get aiChatComingSoonTitle => 'Kuuya nekukurumidza';

  @override
  String get aiChatComingSoonBody => 'Mudzidzisi weAI achauya nekukurumidza.';

  @override
  String get validationRequired => 'Inodiwa';

  @override
  String get validationMustBeNumber => 'Inofanira kuve nhamba';
}

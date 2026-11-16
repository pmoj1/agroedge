// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'AgroEdge';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSignOut => 'Se déconnecter';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonOptional => 'Optionnel';

  @override
  String get commonSomethingWentWrong =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get signInTitle => 'Connexion à AgroEdge';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Mot de passe';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get signInInvalidCredentials => 'Email ou mot de passe incorrect.';

  @override
  String get signInGenericError =>
      'Impossible de se connecter. Veuillez réessayer.';

  @override
  String get farmSetupTitle => 'Configurer votre ferme';

  @override
  String get farmSetupIntro =>
      'Parlez-nous de votre ferme. Vous ne devez le faire qu\'une seule fois.';

  @override
  String get farmSetupFarmNameLabel => 'Nom de la ferme';

  @override
  String get farmSetupFarmSizeLabel => 'Superficie (hectares)';

  @override
  String get farmSetupPrimaryCropLabel => 'Culture principale';

  @override
  String get farmSetupRegionLabel => 'Région';

  @override
  String get farmSetupSaveButton => 'Enregistrer et continuer';

  @override
  String get farmSetupRequiredField => 'Ce champ est obligatoire';

  @override
  String get homeLogActivity => 'Enregistrer une activité';

  @override
  String get homeAskAi => 'Consulter l\'agronome IA';

  @override
  String get homeRecentActivities => 'Activités récentes';

  @override
  String get homeNoActivitiesYet => 'Aucune activité enregistrée.';

  @override
  String get homeLogExpense => 'Enregistrer une dépense';

  @override
  String get homeLogIncome => 'Enregistrer un revenu';

  @override
  String get homeAiInsightsHeading => 'Insights IA';

  @override
  String get homeCropPlanHeading => 'Plan de culture actuel';

  @override
  String get homeCropPlanEmpty => 'Aucun plan de culture.';

  @override
  String get homeInsightsHeading => 'Insights récents';

  @override
  String get homeInsightsEmpty => 'Aucun insight.';

  @override
  String activityListItemSubtitle(String crop, String date) {
    return '$crop — $date';
  }

  @override
  String get logActivityTitle => 'Enregistrer une activité';

  @override
  String get logActivityTypeLabel => 'Type d\'activité';

  @override
  String get logActivityCropLabel => 'Culture';

  @override
  String get logActivityDateLabel => 'Date';

  @override
  String get logActivityNotesLabel => 'Notes';

  @override
  String get logActivityYieldQuantityLabel => 'Quantité de rendement';

  @override
  String get logActivityYieldUnitLabel => 'Unité de rendement';

  @override
  String get logActivitySavedConfirmation => 'Activité enregistrée.';

  @override
  String get logExpenseTitle => 'Enregistrer une dépense';

  @override
  String get logExpenseAmountLabel => 'Montant';

  @override
  String get logExpenseCategoryLabel => 'Catégorie';

  @override
  String get logExpenseDateLabel => 'Date';

  @override
  String get logExpenseNotesLabel => 'Notes';

  @override
  String get logExpenseSavedConfirmation => 'Dépense enregistrée.';

  @override
  String get logIncomeTitle => 'Enregistrer un revenu';

  @override
  String get logIncomeCropLabel => 'Culture';

  @override
  String get logIncomeBuyerLabel => 'Acheteur';

  @override
  String get logIncomeDateLabel => 'Date';

  @override
  String get logIncomePricePerUnitLabel => 'Prix par unité';

  @override
  String get logIncomeQuantitySoldLabel => 'Quantité vendue';

  @override
  String get logIncomeTotalRevenueLabel => 'Revenu total';

  @override
  String get logIncomeSavedConfirmation => 'Revenu enregistré.';

  @override
  String get aiChatTitle => 'Agronome IA';

  @override
  String get aiChatComingSoonTitle => 'Bientôt disponible';

  @override
  String get aiChatComingSoonBody => 'L\'agronome IA sera bientôt disponible.';

  @override
  String get validationRequired => 'Obligatoire';

  @override
  String get validationMustBeNumber => 'Doit être un nombre';
}

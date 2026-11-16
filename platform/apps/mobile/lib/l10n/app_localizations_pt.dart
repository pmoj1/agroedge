// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'AgroEdge';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSignOut => 'Sair';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonOptional => 'Opcional';

  @override
  String get commonSomethingWentWrong =>
      'Algo correu mal. Por favor tente novamente.';

  @override
  String get signInTitle => 'Entrar no AgroEdge';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Palavra-passe';

  @override
  String get signInButton => 'Entrar';

  @override
  String get signInInvalidCredentials => 'Email ou palavra-passe incorretos.';

  @override
  String get signInGenericError =>
      'Não foi possível entrar. Por favor tente novamente.';

  @override
  String get farmSetupTitle => 'Configurar a sua quinta';

  @override
  String get farmSetupIntro =>
      'Conte-nos um pouco sobre a sua quinta. Só precisa fazer isto uma vez.';

  @override
  String get farmSetupFarmNameLabel => 'Nome da quinta';

  @override
  String get farmSetupFarmSizeLabel => 'Tamanho da quinta (hectares)';

  @override
  String get farmSetupPrimaryCropLabel => 'Cultura principal';

  @override
  String get farmSetupRegionLabel => 'Região';

  @override
  String get farmSetupSaveButton => 'Guardar e continuar';

  @override
  String get farmSetupRequiredField => 'Este campo é obrigatório';

  @override
  String get homeLogActivity => 'Registar actividade';

  @override
  String get homeAskAi => 'Perguntar ao agrónomo IA';

  @override
  String get homeRecentActivities => 'Actividades recentes';

  @override
  String get homeNoActivitiesYet => 'Nenhuma actividade registada.';

  @override
  String get homeLogExpense => 'Registar despesa';

  @override
  String get homeLogIncome => 'Registar rendimento';

  @override
  String get homeAiInsightsHeading => 'Insights IA';

  @override
  String get homeCropPlanHeading => 'Plano de culturas actual';

  @override
  String get homeCropPlanEmpty => 'Nenhum plano de culturas.';

  @override
  String get homeInsightsHeading => 'Insights recentes';

  @override
  String get homeInsightsEmpty => 'Nenhum insight.';

  @override
  String activityListItemSubtitle(String crop, String date) {
    return '$crop — $date';
  }

  @override
  String get logActivityTitle => 'Registar actividade';

  @override
  String get logActivityTypeLabel => 'Tipo de actividade';

  @override
  String get logActivityCropLabel => 'Cultura';

  @override
  String get logActivityDateLabel => 'Data';

  @override
  String get logActivityNotesLabel => 'Notas';

  @override
  String get logActivityYieldQuantityLabel => 'Quantidade de produção';

  @override
  String get logActivityYieldUnitLabel => 'Unidade de produção';

  @override
  String get logActivitySavedConfirmation => 'Actividade registada.';

  @override
  String get logExpenseTitle => 'Registar despesa';

  @override
  String get logExpenseAmountLabel => 'Valor';

  @override
  String get logExpenseCategoryLabel => 'Categoria';

  @override
  String get logExpenseDateLabel => 'Data';

  @override
  String get logExpenseNotesLabel => 'Notas';

  @override
  String get logExpenseSavedConfirmation => 'Despesa registada.';

  @override
  String get logIncomeTitle => 'Registar rendimento';

  @override
  String get logIncomeCropLabel => 'Cultura';

  @override
  String get logIncomeBuyerLabel => 'Comprador';

  @override
  String get logIncomeDateLabel => 'Data';

  @override
  String get logIncomePricePerUnitLabel => 'Preço por unidade';

  @override
  String get logIncomeQuantitySoldLabel => 'Quantidade vendida';

  @override
  String get logIncomeTotalRevenueLabel => 'Rendimento total';

  @override
  String get logIncomeSavedConfirmation => 'Rendimento registado.';

  @override
  String get aiChatTitle => 'Agrónomo IA';

  @override
  String get aiChatComingSoonTitle => 'Em breve';

  @override
  String get aiChatComingSoonBody =>
      'O agrónomo IA estará disponível em breve.';

  @override
  String get validationRequired => 'Obrigatório';

  @override
  String get validationMustBeNumber => 'Deve ser um número';
}

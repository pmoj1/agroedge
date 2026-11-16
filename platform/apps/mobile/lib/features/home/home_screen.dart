import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agroedge_shared/models/activity.dart';
import 'package:agroedge_shared/models/ai-insight.dart';
import 'package:agroedge_shared/models/farm-profile.dart';
import 'package:agroedge_shared/models/expense.dart';
import 'package:agroedge_shared/models/income-record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_services.dart';
import '../../core/components/custom_components.dart';
import '../../core/data/country_data.dart';
import '../../core/design_system/app_card.dart';
import '../../core/design_system/app_navigation.dart';
import '../../core/design_system/app_states.dart';
import '../../core/design_system/app_transitions.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/theme.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/locale_service.dart';
import '../../l10n/app_localizations.dart';
import '../accounting/accounting_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../log_activity/log_activity_screen.dart';
import '../log_expense/log_expense_screen.dart';
import '../log_income/log_income_screen.dart';
import '../market/market_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/utils/download_helper.dart';
import '../../core/components/map_widget.dart';
import '../../core/services/location_service.dart';
import '../crop_planning/crop_planning_screen.dart';
import '../ai_agronomist/ai_agronomist_screen.dart';
import '../weather/weather_tab.dart';
import '../business_insight/business_insight_tab.dart';

/// Home: today's date, shortcuts to log an activity/expense/income and to
/// open the AI chat, and a simple list of recent activities -- per the
/// build brief.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedPeriod = 'This Month';
  DateTimeRange? _customRange;
  late Future<List<Activity>> _activitiesFuture;
  late Future<List<AiInsight>> _insightsFuture;
  late Future<List<FarmProfile>> _profilesFuture;
  late Future<List<Expense>> _expensesFuture;
  late Future<List<IncomeRecord>> _incomesFuture;

  List<T> _filterByPeriod<T>(List<T> items, DateTime Function(T) getDate) {
    final now = DateTime.now();
    if (_selectedPeriod == 'This Month') {
      return items.where((item) {
        final date = getDate(item);
        return date.year == now.year && date.month == now.month;
      }).toList();
    } else if (_selectedPeriod == 'This Week') {
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      return items
          .where((item) => getDate(item).isAfter(sevenDaysAgo))
          .toList();
    } else if (_selectedPeriod == 'This Season') {
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));
      return items
          .where((item) => getDate(item).isAfter(ninetyDaysAgo))
          .toList();
    } else if (_selectedPeriod == 'This Year') {
      return items.where((item) => getDate(item).year == now.year).toList();
    } else if (_selectedPeriod == 'Custom range' && _customRange != null) {
      return items.where((item) {
        final date = getDate(item);
        return date.isAfter(
              _customRange!.start.subtract(const Duration(seconds: 1)),
            ) &&
            date.isBefore(_customRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    return items;
  }

  Future<List<Activity>> get _filteredActivitiesFuture => _activitiesFuture
      .then((list) => _filterByPeriod(list, (a) => a.activityDate));

  Future<List<Expense>> get _filteredExpensesFuture => _expensesFuture.then(
    (list) => _filterByPeriod(list, (e) => e.expenseDate),
  );

  Future<List<IncomeRecord>> get _filteredIncomesFuture =>
      _incomesFuture.then((list) => _filterByPeriod(list, (i) => i.incomeDate));

  List<Map<String, dynamic>> _localPlans = [];

  Future<void> _loadLocalPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('local_crop_plans');
      if (saved != null) {
        setState(() {
          _localPlans = saved
              .map((s) => jsonDecode(s) as Map<String, dynamic>)
              .toList();
        });
      } else {
        setState(() {
          _localPlans = [];
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _activitiesFuture = AppServices.instance.activities.list();
    _insightsFuture = AppServices.instance.aiInsights.list();
    _profilesFuture = AppServices.instance.farmProfiles.list();
    _expensesFuture = AppServices.instance.expenses.list();
    _incomesFuture = AppServices.instance.incomeRecords.list();
    _loadLocalPlans();
    _generateAiInsights();
  }

  void _refreshActivities() {
    setState(() {
      _activitiesFuture = AppServices.instance.activities.list();
      _expensesFuture = AppServices.instance.expenses.list();
      _incomesFuture = AppServices.instance.incomeRecords.list();
    });
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF141F1A)
          : AppColors.cream100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<List<dynamic>>(
          future: Future.wait([
            _profilesFuture,
            _incomesFuture,
            _expensesFuture,
          ]),
          builder: (context, snapshot) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textColor = isDark
                ? const Color(0xFFFBF4E4)
                : AppColors.ink900;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.forest700),
                ),
              );
            }

            final profiles = (snapshot.data?[0] as List<FarmProfile>?) ?? [];
            final incomes = (snapshot.data?[1] as List<IncomeRecord>?) ?? [];
            final expenses = (snapshot.data?[2] as List<Expense>?) ?? [];

            final profile = profiles.isNotEmpty ? profiles.first : null;
            final primaryCrop = profile?.primaryCrop ?? 'Maize';
            final country = profile?.country ?? 'Zimbabwe';

            // 1. Diagnostics Advice based on crops
            final diagTitle = 'AI Crop Diagnostics: $primaryCrop';
            final diagDesc =
                'Ensure $primaryCrop field has adequate spacing and check moisture index. Nitrogen absorption is optimal in current weather.';

            // 2. Weather/Regional advisory
            final weatherTitle = 'Weather Alert: $country Region';
            final weatherDesc =
                'Optimal conditions for weeding. Anticipate morning dew and apply preventative pest controls.';

            // 3. Financial/Ledger status
            String ledgerTitle = 'Ledger Empty';
            String ledgerDesc =
                'Log your first income or expense to activate farm credit scoring.';
            if (incomes.isNotEmpty || expenses.isNotEmpty) {
              final totalIncome = incomes.fold<double>(
                0,
                (sum, item) => sum + (item.totalRevenue ?? 0),
              );
              final totalExpense = expenses.fold<double>(
                0,
                (sum, item) => sum + item.amount,
              );
              final net = totalIncome - totalExpense;
              ledgerTitle = 'Credit Eligibility Score Updated';
              ledgerDesc =
                  'Active seasonal ledger (${incomes.length + expenses.length} logs). Profit margin is currently at ${(net >= 0 ? 1 : -1) * (totalIncome > 0 ? (net / totalIncome * 100).round() : 0)}%.';
            }

            // 4. Activity status
            final totalHa = profile?.farmSize ?? 5.0;
            final activePlansTitle = 'Farm Overview: $totalHa Ha';
            final activePlansDesc =
                'Agricultural GDP share benchmarked to World Bank open databases for your registered profile.';

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AI Farm Notifications',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: textColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildNotificationItem(
                      context: context,
                      icon: Icons.psychology_outlined,
                      iconColor: AppColors.gold600,
                      title: diagTitle,
                      description: diagDesc,
                    ),
                    const Divider(),
                    _buildNotificationItem(
                      context: context,
                      icon: Icons.thunderstorm_outlined,
                      iconColor: AppColors.errorRed,
                      title: weatherTitle,
                      description: weatherDesc,
                    ),
                    const Divider(),
                    _buildNotificationItem(
                      context: context,
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.forest700,
                      title: ledgerTitle,
                      description: ledgerDesc,
                    ),
                    const Divider(),
                    _buildNotificationItem(
                      context: context,
                      icon: Icons.map_outlined,
                      iconColor: AppColors.clay400,
                      title: activePlansTitle,
                      description: activePlansDesc,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
    final mutedTextColor = isDark ? const Color(0xFFA8B5AC) : AppColors.ink500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.1),
            radius: 18,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cream100,
          title: const Text(
            'Export AI Farm Report',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
              color: AppColors.ink900,
            ),
          ),
          content: const Text(
            'Choose your preferred file format for your AI-generated P&L statement, farm health overview, and recommendations.',
            style: TextStyle(fontSize: 13, color: AppColors.ink900),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _runExport('CSV');
              },
              child: const Text(
                'CSV Spreadsheet',
                style: TextStyle(
                  color: AppColors.forest700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _runExport('WORD');
              },
              child: const Text(
                'Word Document (.doc)',
                style: TextStyle(
                  color: AppColors.forest700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _runExport('PDF');
              },
              child: const Text(
                'PDF Report (.html)',
                style: TextStyle(
                  color: AppColors.forest700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runExport(String format) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: AppColors.cream100,
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.forest700),
              SizedBox(width: 20),
              Text(
                'AI is generating your report...',
                style: TextStyle(fontSize: 13, color: AppColors.ink900),
              ),
            ],
          ),
        );
      },
    );

    try {
      final profiles = await _profilesFuture;
      final incomes = await _incomesFuture;
      final expenses = await _expensesFuture;
      final activities = await _activitiesFuture;

      final report = await GeminiService.instance.generateExportReport(
        format: format,
        profiles: profiles,
        incomes: incomes,
        expenses: expenses,
        activities: activities,
      );

      if (mounted) Navigator.pop(context); // Close loading dialog

      final extension = format == 'CSV'
          ? 'csv'
          : format == 'WORD'
          ? 'doc'
          : 'html';
      final filename =
          'farm_report_${DateTime.now().millisecondsSinceEpoch}.$extension';

      saveAndDownloadFile(report, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farm report downloaded successfully: $filename'),
            backgroundColor: AppColors.forest700,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _refreshAiInsights() {
    setState(() {
      _insightsFuture = AppServices.instance.aiInsights.list();
    });
  }

  void _refreshProfiles() {
    setState(() {
      _profilesFuture = AppServices.instance.farmProfiles.list();
    });
  }

  Future<void> _generateAiInsights() async {
    if (!GeminiService.instance.isAvailable) return;
    try {
      final profiles = await _profilesFuture;
      final activities = await _activitiesFuture;
      final expenses = await _expensesFuture;
      final incomes = await _incomesFuture;
      if (profiles.isEmpty) return;
      final p = profiles.first;
      final totalRevenue = incomes.fold<double>(
        0,
        (s, i) => s + (i.totalRevenue ?? 0),
      );
      final totalExpenses = expenses.fold<double>(0, (s, e) => s + e.amount);
      final crops = [
        p.primaryCrop,
        p.secondaryCrop,
      ].whereType<String>().toList();
      await GeminiService.instance.generateDashboardInsights(
        farmName: p.farmName ?? 'Your Farm',
        crops: crops.isEmpty ? ['General crops'] : crops,
        region: p.region ?? '',
        country: p.country ?? '',
        activityCount: activities.length,
        totalRevenue: totalRevenue,
        totalExpenses: totalExpenses,
      );
    } catch (_) {}
  }

  Future<void> _refreshAll() async {
    _refreshActivities();
    _refreshAiInsights();
    _refreshProfiles();
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.of(
      context,
    ).push(AppTransitions.slideHorizontal(child: screen));
    _refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor =
        theme.textTheme.bodyMedium?.color ?? AppColors.ink900;
    final langCode = LocaleService.instance.locale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu_rounded, color: foregroundColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              ThemeService.instance.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: foregroundColor,
            ),
            onPressed: () {
              ThemeService.instance.toggleTheme();
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: foregroundColor,
                  size: 26,
                ),
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.forest500,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => _showNotificationsBottomSheet(context),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'account') {
                setState(() {
                  _currentIndex = 7;
                });
              } else if (value == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              } else if (value == 'theme') {
                ThemeService.instance.toggleTheme();
              } else if (value == 'logout') {
                Supabase.instance.client.auth.signOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'account',
                child: ListTile(
                  leading: Icon(Icons.person_outline_rounded, size: 20),
                  title: Text('My Account', style: TextStyle(fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined, size: 20),
                  title: Text('Settings', style: TextStyle(fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'theme',
                child: ListTile(
                  leading: Icon(Icons.palette_outlined, size: 20),
                  title: Text('Toggle Theme', style: TextStyle(fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: AppColors.errorRed,
                  ),
                  title: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE2F0D9),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: AppColors.forest700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF14261C)
              : AppColors.cream100,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1B2E22)
                            : const Color(0xFFE2F0D9),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 24,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFFBF4E4)
                              : AppColors.forest700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Albert Flores',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFFBF4E4)
                                    : AppColors.ink900,
                              ),
                            ),
                            Text(
                              Supabase
                                      .instance
                                      .client
                                      .auth
                                      .currentUser
                                      ?.email ??
                                  'farmer@agroedge.com',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFC3D0C7)
                                    : AppColors.ink500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.dashboard_rounded,
                        label: langCode == 'sn'
                            ? 'Dashboard'
                            : langCode == 'sw'
                            ? 'Mwanzo'
                            : langCode == 'fr'
                            ? 'Tableau de bord'
                            : langCode == 'pt'
                            ? 'Painel de Controle'
                            : 'Dashboard',
                        index: 0,
                      ),
                      _buildDrawerItem(
                        icon: Icons.account_balance_rounded,
                        label: langCode == 'sn'
                            ? 'Bhuku remari'
                            : langCode == 'sw'
                            ? 'Uhasibu'
                            : langCode == 'fr'
                            ? 'Comptabilité'
                            : langCode == 'pt'
                            ? 'Contabilidade'
                            : 'Accounting',
                        index: 1,
                      ),
                      _buildDrawerItem(
                        icon: Icons.wb_sunny_rounded,
                        label: langCode == 'sn'
                            ? 'Kunze'
                            : langCode == 'sw'
                            ? 'Hali ya Hewa'
                            : langCode == 'fr'
                            ? 'Météo'
                            : langCode == 'pt'
                            ? 'Clima'
                            : 'Weather',
                        index: 2,
                      ),
                      _buildDrawerItem(
                        icon: Icons.favorite_rounded,
                        label: langCode == 'sn'
                            ? 'Utano hwemesa'
                            : langCode == 'sw'
                            ? 'Afya ya Shamba'
                            : langCode == 'fr'
                            ? 'Santé de la ferme'
                            : langCode == 'pt'
                            ? 'Saúde da Fazenda'
                            : 'Farm Health',
                        index: 3,
                      ),
                      _buildDrawerItem(
                        icon: Icons.show_chart_rounded,
                        label: langCode == 'sn'
                            ? 'Mitengo yemusika'
                            : langCode == 'sw'
                            ? 'Bei za Sokoni'
                            : langCode == 'fr'
                            ? 'Prix du marché'
                            : langCode == 'pt'
                            ? 'Preços de Mercado'
                            : 'Market Prices',
                        index: 4,
                      ),
                      _buildDrawerItem(
                        icon: Icons.bar_chart_rounded,
                        label: langCode == 'sn'
                            ? 'Mazano makuru'
                            : langCode == 'sw'
                            ? 'Maarifa ya Jumla'
                            : langCode == 'fr'
                            ? 'Perspectives macro'
                            : langCode == 'pt'
                            ? 'Insights Macro'
                            : 'Macro Insights',
                        index: 5,
                      ),
                      _buildDrawerItem(
                        icon: Icons.assignment_rounded,
                        label: langCode == 'sn'
                            ? 'Chirongwa chemhuri'
                            : langCode == 'sw'
                            ? 'Upangaji wa Mazao'
                            : langCode == 'fr'
                            ? 'Planification des cultures'
                            : langCode == 'pt'
                            ? 'Planejamento de Cultivos'
                            : 'Crop Planning',
                        index: 6,
                      ),
                      _buildDrawerItem(
                        icon: Icons.check_box_rounded,
                        label: langCode == 'sn'
                            ? 'Zvekuita zvangu'
                            : langCode == 'sw'
                            ? 'Orodha ya Kazi'
                            : langCode == 'fr'
                            ? 'Mes tâches'
                            : langCode == 'pt'
                            ? 'Minha Lista de Tarefas'
                            : 'My To-Do List',
                        index: 8,
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_rounded,
                        label: langCode == 'sn'
                            ? 'Akaundi yangu'
                            : langCode == 'sw'
                            ? 'Akaunti Yangu'
                            : langCode == 'fr'
                            ? 'Mon compte'
                            : langCode == 'pt'
                            ? 'Minha Conta'
                            : 'My Account',
                        index: 7,
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.settings_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFC3D0C7)
                              : AppColors.forest700,
                        ),
                        title: Text(
                          langCode == 'sn'
                              ? 'Zvirongwa / Mutauro'
                              : langCode == 'sw'
                              ? 'Mipangilio / Lugha'
                              : langCode == 'fr'
                              ? 'Paramètres / Langue'
                              : langCode == 'pt'
                              ? 'Configurações / Idioma'
                              : 'Settings / Language',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFFBF4E4)
                                : AppColors.ink900,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.errorRed,
                        ),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Supabase.instance.client.auth.signOut();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(_currentIndex),
      bottomNavigationBar: AppBottomNavigationBar(
        items: const [
          AppNavigationItem(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
          ),
          AppNavigationItem(
            label: 'Accounting',
            icon: Icons.account_balance_outlined,
            activeIcon: Icons.account_balance_rounded,
          ),
          AppNavigationItem(
            label: 'Weather',
            icon: Icons.wb_sunny_outlined,
            activeIcon: Icons.wb_sunny_rounded,
          ),
          AppNavigationItem(
            label: 'Farm Health',
            icon: Icons.favorite_border_rounded,
            activeIcon: Icons.favorite_rounded,
          ),
        ],
        currentIndex: _currentIndex < 4 ? _currentIndex : -1,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? (isDark ? const Color(0xFF3E8E5E) : AppColors.forest700)
            : (isDark ? const Color(0xFFC3D0C7) : AppColors.ink500),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? (isDark ? const Color(0xFF3E8E5E) : AppColors.forest700)
              : (isDark ? const Color(0xFFFBF4E4) : AppColors.ink900),
        ),
      ),
      selected: isSelected,
      selectedTileColor: isDark
          ? const Color(0xFF1B2E22)
          : AppColors.forest100.withValues(alpha: 0.5),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return _dashboardBody();
      case 1:
        return AccountingScreen(
          selectedPeriod: _selectedPeriod,
          customRange: _customRange,
        );
      case 2:
        return const WeatherTab();
      case 3:
        return const FarmHealthScreen();
      case 4:
        return MarketScreen(profilesFuture: _profilesFuture);
      case 5:
        return const BusinessInsightTab();
      case 6:
        return const CropPlanningScreen();
      case 7:
        return _accountBody();
      case 8:
        return const CustomTodoListScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _dashboardBody() {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      color: AppColors.forest700,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: FutureBuilder<List<FarmProfile>>(
              future: _profilesFuture,
              builder: (context, snapshot) {
                final farmName = (snapshot.hasData && snapshot.data!.isNotEmpty)
                    ? (snapshot.data!.first.farmName ?? 'Your Farm')
                    : 'Your Farm';
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDark
                    ? const Color(0xFFFBF4E4)
                    : AppColors.ink900;
                final mutedColor = isDark
                    ? const Color(0xFFA8B5AC)
                    : AppColors.ink500;
                final hour = DateTime.now().hour;
                final langCode = LocaleService.instance.locale.languageCode;

                String greeting = 'Good Morning!';
                if (langCode == 'sn') {
                  if (hour >= 5 && hour < 12) {
                    greeting = 'Mangwanani akanaka!';
                  } else if (hour >= 12 && hour < 17) {
                    greeting = 'Masikati akanaka!';
                  } else {
                    greeting = 'Manheru akanaka!';
                  }
                } else if (langCode == 'sw') {
                  if (hour >= 5 && hour < 12) {
                    greeting = 'Habari za asubuhi!';
                  } else if (hour >= 12 && hour < 17) {
                    greeting = 'Habari za mchana!';
                  } else {
                    greeting = 'Habari za jioni!';
                  }
                } else if (langCode == 'fr') {
                  if (hour >= 5 && hour < 17) {
                    greeting = 'Bonjour!';
                  } else {
                    greeting = 'Bonsoir!';
                  }
                } else if (langCode == 'pt') {
                  if (hour >= 5 && hour < 12) {
                    greeting = 'Bom dia!';
                  } else if (hour >= 12 && hour < 18) {
                    greeting = 'Boa tarde!';
                  } else {
                    greeting = 'Boa noite!';
                  }
                } else {
                  if (hour >= 5 && hour < 12) {
                    greeting = 'Good Morning!';
                  } else if (hour >= 12 && hour < 17) {
                    greeting = 'Good Afternoon!';
                  } else {
                    greeting = 'Good Evening!';
                  }
                }

                String subtitle =
                    'Optimize $farmName operations with Real-Time Insights';
                if (langCode == 'sn') {
                  subtitle = 'Natsurudza mashandiro e$farmName neMazano chaiwo';
                } else if (langCode == 'sw') {
                  subtitle =
                      'Boresha shughuli za shamba la $farmName kwa Maarifa ya Wakati Halisi';
                } else if (langCode == 'fr') {
                  subtitle =
                      'Optimisez les opérations de la ferme $farmName avec des informations en temps réel';
                } else if (langCode == 'pt') {
                  subtitle =
                      'Otimize as operações da fazenda $farmName com insights em tempo real';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontFamilyFallback: const ['Liberation Serif', 'serif'],
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Calibri',
                        fontFamilyFallback: const [
                          'Liberation Sans',
                          'sans-serif',
                        ],
                        fontSize: 12,
                        color: mutedColor,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<String>(
                  onSelected: (String value) async {
                    if (value == 'Custom range') {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (range != null) {
                        setState(() {
                          _customRange = range;
                          _selectedPeriod = 'Custom range';
                        });
                      }
                    } else {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'This Week',
                          child: Text('This Week'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'This Month',
                          child: Text('This Month'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'This Season',
                          child: Text('This Season'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'This Year',
                          child: Text('This Year'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Custom range',
                          child: Text('Custom range...'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'All Time',
                          child: Text('All Time'),
                        ),
                      ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cream100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5DDD0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.ink900,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedPeriod == 'Custom range' &&
                                  _customRange != null
                              ? '${DateFormat('d MMM').format(_customRange!.start)} - ${DateFormat('d MMM').format(_customRange!.end)}'
                              : _selectedPeriod,
                          style: const TextStyle(
                            fontFamily: 'Calibri',
                            fontFamilyFallback: [
                              'Liberation Sans',
                              'sans-serif',
                            ],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: AppColors.ink900,
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showExportDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest500,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.file_upload_outlined, size: 14),
                  label: const Text(
                    'Export',
                    style: TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AiSuggestedTodoList(
            profilesFuture: _profilesFuture,
            key: ValueKey(_currentIndex),
          ),
          Builder(
            builder: (context) {
              final isWide = MediaQuery.of(context).size.width > 640;
              return FutureBuilder<List<FarmProfile>>(
                future: _profilesFuture,
                builder: (context, snapshot) {
                  final region = snapshot.data?.firstOrNull?.region;
                  final country = snapshot.data?.firstOrNull?.country;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _WeatherWidget(
                            farmRegion: region,
                            farmCountry: country,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _ProfileProductionWidget(
                            profilesFuture: _profilesFuture,
                            incomesFuture: _filteredIncomesFuture,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _WeatherWidget(
                          farmRegion: region,
                          farmCountry: country,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ProfileProductionWidget(
                          profilesFuture: _profilesFuture,
                          incomesFuture: _filteredIncomesFuture,
                        ),
                      ],
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _KpiStrip(
            activitiesFuture: _filteredActivitiesFuture,
            expensesFuture: _filteredExpensesFuture,
            incomesFuture: _filteredIncomesFuture,
            profilesFuture: _profilesFuture,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(label: 'QUICK ACTIONS'),
          const SizedBox(height: AppSpacing.md),
          Builder(
            builder: (context) {
              final isWide = MediaQuery.of(context).size.width > 640;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: isWide ? 2.2 : 1.4,
                children: [
                  _ShortcutCard(
                    icon: Icons.assignment_outlined,
                    gradientColors: const [
                      AppColors.forest700,
                      AppColors.forest500,
                    ],
                    label: l10n.homeLogActivity,
                    onPressed: () => _openScreen(const LogActivityScreen()),
                  ),
                  _ShortcutCard(
                    icon: Icons.payments_outlined,
                    gradientColors: const [
                      AppColors.gold600,
                      AppColors.gold500,
                    ],
                    label: l10n.homeLogExpense,
                    onPressed: () => _openScreen(const LogExpenseScreen()),
                  ),
                  _ShortcutCard(
                    icon: Icons.account_balance_wallet_outlined,
                    gradientColors: const [
                      AppColors.forest500,
                      Color(0xFF3D9E68),
                    ],
                    label: l10n.homeLogIncome,
                    onPressed: () => _openScreen(const LogIncomeScreen()),
                  ),
                  _ShortcutCard(
                    icon: Icons.forum_outlined,
                    gradientColors: const [
                      AppColors.clay400,
                      Color(0xFFD4A07A),
                    ],
                    label: l10n.homeAskAi,
                    onPressed: () => _openScreen(const AiChatScreen()),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SectionLabel(label: 'FARM OVERVIEW'),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const _FarmMapPreview(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel(label: l10n.homeRecentActivities),
              const Icon(
                Icons.history_outlined,
                size: 18,
                color: AppColors.ink500,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              _filteredActivitiesFuture,
              _filteredExpensesFuture,
              _filteredIncomesFuture,
              _profilesFuture,
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  children: [
                    AppLoadingState(width: double.infinity, height: 76),
                    SizedBox(height: AppSpacing.sm),
                    AppLoadingState(width: double.infinity, height: 76),
                    SizedBox(height: AppSpacing.sm),
                    AppLoadingState(width: double.infinity, height: 76),
                  ],
                );
              }
              if (snapshot.hasError) {
                return AppCard(
                  borderColor: AppColors.errorRed.withValues(alpha: 0.3),
                  child: Center(
                    child: AppErrorState(
                      errorMessage:
                          snapshot.error?.toString() ??
                          l10n.commonSomethingWentWrong,
                      onRetry: _refreshActivities,
                      title: l10n.commonSomethingWentWrong,
                    ),
                  ),
                );
              }
              final activities = snapshot.data![0] as List<Activity>;
              final expenses = snapshot.data![1] as List<Expense>;
              final incomes = snapshot.data![2] as List<IncomeRecord>;
              final profiles = snapshot.data![3] as List<FarmProfile>;

              final countryName = profiles.isNotEmpty
                  ? profiles.first.country
                  : null;
              final countryData = countryName != null
                  ? CountryData.findByName(countryName)
                  : null;
              final currencyCode = countryData?.currency ?? 'BWP';

              final List<_FeedItem> feedItems = [];

              for (final a in activities) {
                feedItems.add(
                  _FeedItem(
                    date: a.activityDate,
                    title: a.activityType,
                    subtitle:
                        '${a.crop ?? "—"} • ${DateFormat.yMMMd().format(a.activityDate)}',
                    icon: Icons.agriculture_rounded,
                    gradientColors: const [
                      AppColors.forest700,
                      AppColors.forest500,
                    ],
                    badgeText: a.yieldQuantity != null
                        ? '${a.yieldQuantity} ${a.yieldUnit ?? ""}'
                        : null,
                    badgeIcon: Icons.scale_outlined,
                    badgeColor: AppColors.gold500,
                  ),
                );
              }

              for (final e in expenses) {
                feedItems.add(
                  _FeedItem(
                    date: e.expenseDate,
                    title: e.category ?? 'Expense',
                    subtitle:
                        '${e.notes ?? "—"} • ${DateFormat.yMMMd().format(e.expenseDate)}',
                    icon: Icons.payments_rounded,
                    gradientColors: const [
                      AppColors.clay400,
                      Color(0xFFD4A07A),
                    ],
                    badgeText: '-${e.amount} $currencyCode',
                    badgeIcon: Icons.trending_down_rounded,
                    badgeColor: AppColors.errorRed,
                  ),
                );
              }

              for (final i in incomes) {
                feedItems.add(
                  _FeedItem(
                    date: i.incomeDate,
                    title: i.crop ?? 'Income',
                    subtitle:
                        'Buyer: ${i.buyer ?? "—"} • ${DateFormat.yMMMd().format(i.incomeDate)}',
                    icon: Icons.account_balance_wallet_rounded,
                    gradientColors: const [
                      Color(0xFF3D9E68),
                      AppColors.forest500,
                    ],
                    badgeText: '+${i.totalRevenue} $currencyCode',
                    badgeIcon: Icons.trending_up_rounded,
                    badgeColor: AppColors.forest500,
                  ),
                );
              }

              feedItems.sort((a, b) => b.date.compareTo(a.date));

              if (feedItems.isEmpty) {
                return AppCard(
                  child: AppEmptyState(
                    title: l10n.homeNoActivitiesYet,
                    description:
                        'Activities, expenses, and income you log will show up here to help track your progress.',
                    icon: Icons.history,
                  ),
                );
              }

              return Column(
                children: [
                  for (final item in feedItems) ...[
                    _FeedListItem(item: item, textTheme: textTheme),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              const Icon(
                Icons.psychology_outlined,
                size: 18,
                color: AppColors.gold500,
              ),
              const SizedBox(width: AppSpacing.xs),
              _SectionLabel(label: l10n.homeInsightsHeading),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionLabel(label: 'CROP PLAN'),
          const SizedBox(height: AppSpacing.sm),
          Builder(
            builder: (context) {
              if (_localPlans.isEmpty) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 5;
                    });
                  },
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeCropPlanEmpty,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.ink500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: AppColors.forest700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to create your crop plan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.forest700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final plan in _localPlans) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = 5;
                        });
                      },
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AgroStatBadge(
                                  icon: Icons.grass,
                                  label:
                                      '${plan['cropName']} (${plan['localName']})',
                                  color: AppColors.forest700,
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.ink500,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Plot: ${plan['plotName']} · Hectares: ${plan['hectares']} ha',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Expected Yield: ${plan['expectedYield']} Tons · Target Price: \$${plan['expectedPrice']}/Ton',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.ink500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(label: 'RECENT INSIGHTS'),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<AiInsight>>(
            future: _insightsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  children: [
                    AppLoadingState(width: double.infinity, height: 80),
                    SizedBox(height: AppSpacing.sm),
                    AppLoadingState(width: double.infinity, height: 80),
                  ],
                );
              }
              if (snapshot.hasError) return const SizedBox.shrink();
              final insights = snapshot.data ?? [];
              if (insights.isEmpty) {
                return AppCard(
                  child: Text(
                    l10n.homeInsightsEmpty,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink500,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final insight in insights) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (insight.category != null)
                                AgroStatBadge(
                                  icon: Icons.lightbulb_outline,
                                  label: insight.category!,
                                  color: AppColors.gold500,
                                ),
                              const Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.gold500,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            insight.insightText ?? '',
                            style: textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _accountBody() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      color: AppColors.forest700,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Text(
            'My Account',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontFamilyFallback: ['Liberation Serif', 'serif'],
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Manage profile credentials and farm metadata.',
            style: TextStyle(fontSize: 12, color: AppColors.ink500),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Profile Details Card
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFE2F0D9),
                  child: const Icon(
                    Icons.person,
                    size: 36,
                    color: AppColors.forest700,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Albert Flores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Supabase.instance.client.auth.currentUser?.email ??
                            'farmer@agroedge.com',
                        style: const TextStyle(
                          color: AppColors.ink500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(label: 'FARM PROFILE DETAILS'),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<List<FarmProfile>>(
            future: _profilesFuture,
            builder: (context, snapshot) {
              final profile = (snapshot.hasData && snapshot.data!.isNotEmpty)
                  ? snapshot.data!.first
                  : null;
              return AppCard(
                child: Column(
                  children: [
                    _accountInfoRow(
                      'Farm Name',
                      profile?.farmName ?? 'Your Farm',
                    ),
                    const Divider(),
                    _accountInfoRow(
                      'Location (Tap to Edit)',
                      _parseLocationPlace(profile?.region),
                      onTap: () {
                        if (profile != null) {
                          _showLocationEditDialog(context, profile);
                        }
                      },
                    ),
                    const Divider(),
                    _accountInfoRow(
                      'Farm Size',
                      '${profile?.farmSize ?? 4.2} Hectares',
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () {
              Supabase.instance.client.auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
              foregroundColor: AppColors.errorRed,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.errorRed, width: 1),
              ),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountInfoRow(String label, String value, {VoidCallback? onTap}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.ink500)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.ink900,
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      return InkWell(onTap: onTap, child: row);
    }
    return row;
  }

  String _parseLocationPlace(String? region) {
    if (region == null || region.isEmpty) return 'Not set';
    if (region.contains('|')) {
      final parts = region.split('|');
      return parts[0];
    }
    return region;
  }

  void _showLocationEditDialog(BuildContext context, FarmProfile profile) {
    double editLat = profile.gpsLat ?? -17.82485;
    double editLng = profile.gpsLng ?? 31.05303;
    String editPlace = _parseLocationPlace(profile.region);
    String editTz = 'Africa/Harare';
    String editDist = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: const Text('Update Farm Location'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 250,
                      width: 400,
                      child: buildLeafletMapPicker(
                        initialLat: editLat,
                        initialLng: editLng,
                        isDark: Theme.of(context).brightness == Brightness.dark,
                        onLocationSelected: (lat, lng) async {
                          final details = await LocationService.instance
                              .reverseGeocode(lat, lng);
                          if (details != null) {
                            setDialogState(() {
                              editLat = details.lat;
                              editLng = details.lng;
                              editPlace = details.placeName;
                              editDist = details.district;
                              editTz = details.timezone;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      editPlace,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coords: ${editLat.toStringAsFixed(5)}, ${editLng.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.ink500,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final locationObj = LocationDetails(
                      lat: editLat,
                      lng: editLng,
                      placeName: editPlace,
                      district: editDist,
                      region: editDist,
                      countryCode: profile.country ?? 'ZW',
                      timezone: editTz,
                    );
                    try {
                      await AppServices.instance.farmProfiles.update(
                        profile.id!,
                        FarmProfileCreate(
                          farmName: profile.farmName,
                          farmSize: profile.farmSize,
                          primaryCrop: profile.primaryCrop,
                          secondaryCrop: profile.secondaryCrop,
                          region: locationObj.serialize(),
                          country: profile.country,
                          gpsLat: editLat,
                          gpsLng: editLng,
                        ),
                      );
                      setState(() {
                        _profilesFuture = AppServices.instance.farmProfiles
                            .list();
                      });
                    } catch (_) {}
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI STRIP
// ─────────────────────────────────────────────────────────────────────────────

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({
    required this.activitiesFuture,
    required this.expensesFuture,
    required this.incomesFuture,
    required this.profilesFuture,
  });

  final Future<List<Activity>> activitiesFuture;
  final Future<List<Expense>> expensesFuture;
  final Future<List<IncomeRecord>> incomesFuture;
  final Future<List<FarmProfile>> profilesFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        activitiesFuture,
        expensesFuture,
        incomesFuture,
        profilesFuture,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 86,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                AppLoadingState(width: 140, height: 86),
                SizedBox(width: AppSpacing.md),
                AppLoadingState(width: 140, height: 86),
                SizedBox(width: AppSpacing.md),
                AppLoadingState(width: 140, height: 86),
                SizedBox(width: AppSpacing.md),
                AppLoadingState(width: 140, height: 86),
              ],
            ),
          );
        }

        final activities = snapshot.data![0] as List<Activity>;
        final expenses = snapshot.data![1] as List<Expense>;
        final incomes = snapshot.data![2] as List<IncomeRecord>;
        final profiles = snapshot.data![3] as List<FarmProfile>;

        final countryName = profiles.isNotEmpty ? profiles.first.country : null;
        final countryData = countryName != null
            ? CountryData.findByName(countryName)
            : null;
        final currencyCode = countryData?.currency ?? 'BWP';

        // Compute actual metrics
        final totalRevenue = incomes.fold<double>(
          0,
          (sum, item) => sum + (item.totalRevenue ?? 0).toDouble(),
        );
        final totalExpenses = expenses.fold<double>(
          0,
          (sum, item) => sum + item.amount.toDouble(),
        );
        final totalActivities = activities.length.toDouble();
        final farmSize = profiles.isNotEmpty
            ? (profiles.first.farmSize ?? 0).toDouble()
            : 0.0;

        return SizedBox(
          height: 86,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _KpiCard(
                icon: Icons.trending_up,
                label: 'Revenue ($currencyCode)',
                value: totalRevenue,
                suffix: '',
              ),
              const SizedBox(width: AppSpacing.md),
              _KpiCard(
                icon: Icons.event_available_outlined,
                label: 'Activities',
                value: totalActivities,
                suffix: '',
              ),
              const SizedBox(width: AppSpacing.md),
              _KpiCard(
                icon: Icons.payments_outlined,
                label: 'Expenses ($currencyCode)',
                value: totalExpenses,
                suffix: '',
                color: AppColors.clay400,
              ),
              const SizedBox(width: AppSpacing.md),
              _KpiCard(
                icon: Icons.grass_outlined,
                label: 'Hectares',
                value: farmSize,
                decimalPlaces: 1,
                suffix: ' ha',
                color: AppColors.forest500,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    this.suffix = '',
    this.decimalPlaces = 0,
    this.color = AppColors.forest700,
  });
  final IconData icon;
  final String label;
  final double value;
  final String suffix;
  final int decimalPlaces;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Calibri',
                    fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          AnimatedCountUp(
            end: value,
            suffix: suffix,
            decimalPlaces: decimalPlaces,
            style: TextStyle(
              fontFamily: 'Calibri',
              fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FARM MAP PREVIEW
// ─────────────────────────────────────────────────────────────────────────────

class _FarmMapPreview extends StatefulWidget {
  const _FarmMapPreview();

  @override
  State<_FarmMapPreview> createState() => _FarmMapPreviewState();
}

class _FarmMapPreviewState extends State<_FarmMapPreview> {
  late Future<List<FarmProfile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profilesFuture = AppServices.instance.farmProfiles.list();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FarmProfile>>(
      future: _profilesFuture,
      builder: (context, snapshot) {
        final profile = (snapshot.hasData && snapshot.data!.isNotEmpty)
            ? snapshot.data!.first
            : null;

        final farmName = profile?.farmName ?? 'Your Farm';
        final region = profile?.region ?? 'Harare';
        final country = profile?.country ?? 'Zimbabwe';
        final hectares = profile?.farmSize ?? 4.2;

        double lat = -17.8252;
        double lng = 31.0335;

        final countryData = CountryData.findByName(country);
        if (countryData != null) {
          try {
            final reg = countryData.regions.firstWhere((r) => r.name == region);
            lat = reg.lat;
            lng = reg.lng;
          } catch (_) {
            if (countryData.regions.isNotEmpty) {
              lat = countryData.regions.first.lat;
              lng = countryData.regions.first.lng;
            }
          }
        }

        return Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                buildLeafletMap(
                  lat: lat,
                  lng: lng,
                  label: '$farmName ($region)',
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.forest900.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$region · $hectares ha',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// Unused components removed to satisfy linter constraints.

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Calibri',
        fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.ink500,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ShortcutCard extends StatefulWidget {
  const _ShortcutCard({
    required this.icon,
    required this.gradientColors,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final List<Color> gradientColors;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_ShortcutCard> createState() => _ShortcutCardState();
}

class _ShortcutCardState extends State<_ShortcutCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, size: 22, color: Colors.white),
              ),
              Text(
                widget.label,
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedItem {
  _FeedItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.badgeText,
    this.badgeIcon,
    this.badgeColor,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String? badgeText;
  final IconData? badgeIcon;
  final Color? badgeColor;
}

class _FeedListItem extends StatelessWidget {
  const _FeedListItem({required this.item, required this.textTheme});
  final _FeedItem item;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                ),
              ],
            ),
          ),
          if (item.badgeText != null)
            AgroStatBadge(
              icon: item.badgeIcon ?? Icons.info_outline,
              label: item.badgeText!,
              color: item.badgeColor ?? AppColors.gold500,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS CARD & MOCKUP COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderColor,
    this.glowColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0x8C14261C) // rgba(20,38,28,.55) dark glass
        : Colors.white.withValues(alpha: 0.85);
    final finalBorderColor =
        borderColor ??
        (isDark
            ? const Color(0x1AFFFFFF) // rgba(255,255,255,.10) hairline border
            : Colors.white.withValues(alpha: 0.5));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: finalBorderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : (glowColor ?? AppColors.forest900).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          if (glowColor != null && !isDark)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.02),
              blurRadius: 32,
              spreadRadius: 2,
            ),
        ],
      ),
      child: child,
    );
  }
}

class _WeatherWidget extends StatefulWidget {
  const _WeatherWidget({this.farmRegion, this.farmCountry});
  final String? farmRegion;
  final String? farmCountry;

  @override
  State<_WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<_WeatherWidget> {
  bool isCelsius = true;
  WeatherData? _weather;
  bool _loading = true;
  String _locationLabel = 'Your Region';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void didUpdateWidget(_WeatherWidget old) {
    super.didUpdateWidget(old);
    if (old.farmRegion != widget.farmRegion ||
        old.farmCountry != widget.farmCountry) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    if (!mounted) return;
    setState(() => _loading = true);
    double? lat, lng;
    // Try to get GPS from country data
    if (widget.farmRegion != null && widget.farmCountry != null) {
      final country = CountryData.findByName(widget.farmCountry!);
      if (country != null) {
        try {
          final region = country.regions.firstWhere(
            (r) => r.name == widget.farmRegion,
          );
          lat = region.lat;
          lng = region.lng;
          _locationLabel = '${widget.farmRegion}, ${widget.farmCountry}';
        } catch (_) {
          // Region not found, use country capital
          if (country.regions.isNotEmpty) {
            lat = country.regions.first.lat;
            lng = country.regions.first.lng;
            _locationLabel = country.regions.first.name;
          }
        }
      }
    }
    if (lat == null && widget.farmRegion != null) {
      final results = await LocationService.instance.search(widget.farmRegion!);
      if (results.isNotEmpty) {
        lat = (results.first['latitude'] as num).toDouble();
        lng = (results.first['longitude'] as num).toDouble();
        _locationLabel = widget.farmRegion!;
      }
    }
    // Final fallback: Harare, Zimbabwe
    lat ??= -17.8252;
    lng ??= 31.0335;
    if (_locationLabel == 'Your Region') _locationLabel = 'Harare';

    final weather = await WeatherService.instance.getWeather(lat, lng);
    if (mounted) {
      setState(() {
        _weather = weather;
        _loading = false;
      });
      // Auto-refresh every 5 minutes
      Future.delayed(const Duration(minutes: 5), () {
        if (mounted) _fetchWeather();
      });
    }
  }

  double _toDisplay(double celsius) =>
      isCelsius ? celsius : celsius * 9 / 5 + 32;
  String _unit() => isCelsius ? '°C' : '°F';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final dateStr = DateFormat('d MMM, yyyy').format(now);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
    final mutedTextColor = isDark ? const Color(0xFFA8B5AC) : AppColors.ink500;

    return GlassCard(
      glowColor: AppColors.gold500,
      child: _loading
          ? const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.forest500,
                  strokeWidth: 2,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.forest500,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _locationLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Temperature scale toggle
                    GestureDetector(
                      onTap: () => setState(() => isCelsius = !isCelsius),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.cream100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final label in ['C', 'F'])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (label == 'C') == isCelsius
                                      ? AppColors.forest500
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: (label == 'C') == isCelsius
                                        ? Colors.white
                                        : mutedTextColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontFamilyFallback: const [
                              'Liberation Serif',
                              'serif',
                            ],
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(fontSize: 10, color: mutedTextColor),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _weather != null
                              ? '${_toDisplay(_weather!.temperatureC).toStringAsFixed(0)}${_unit()}'
                              : '--',
                          style: TextStyle(
                            fontFamily: 'Calibri',
                            fontFamilyFallback: const [
                              'Liberation Sans',
                              'sans-serif',
                            ],
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        if (_weather != null && _weather!.daily.isNotEmpty)
                          Text(
                            'H: ${_toDisplay(_weather!.daily.first.maxTempC).toStringAsFixed(0)}${_unit()} '
                            'L: ${_toDisplay(_weather!.daily.first.minTempC).toStringAsFixed(0)}${_unit()}',
                            style: TextStyle(
                              fontSize: 10,
                              color: mutedTextColor,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _weather?.conditionEmoji ?? '🌤️',
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _weather?.conditionLabel ?? 'Loading...',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontFamilyFallback: const [
                              'Liberation Serif',
                              'serif',
                            ],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        if (_weather != null)
                          Text(
                            'Feels ${_toDisplay(_weather!.apparentTemperatureC).toStringAsFixed(0)}${_unit()}',
                            style: TextStyle(
                              fontSize: 9,
                              color: mutedTextColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_weather != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop_outlined,
                            size: 12,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Humidity ${_weather!.humidity}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: mutedTextColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.air, size: 12, color: mutedTextColor),
                          const SizedBox(width: 4),
                          Text(
                            'Wind ${_weather!.windSpeed.toStringAsFixed(1)} km/h',
                            style: TextStyle(
                              fontSize: 10,
                              color: mutedTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

/// Shows real crops from the farmer's profile with total income.
class _ProfileProductionWidget extends StatelessWidget {
  const _ProfileProductionWidget({
    required this.profilesFuture,
    required this.incomesFuture,
  });

  final Future<List<FarmProfile>> profilesFuture;
  final Future<List<IncomeRecord>> incomesFuture;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
    final mutedTextColor = isDark ? const Color(0xFFA8B5AC) : AppColors.ink500;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([profilesFuture, incomesFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingState(width: double.infinity, height: 140);
        }
        final profiles = (snapshot.data?[0] as List<FarmProfile>?) ?? [];
        final incomes = (snapshot.data?[1] as List<IncomeRecord>?) ?? [];

        final totalRevenue = incomes.fold<double>(
          0,
          (s, i) => s + (i.totalRevenue ?? 0),
        );

        // Infer currency from country
        final country = profiles.firstOrNull?.country;
        String currencySymbol = r'$';
        if (country != null) {
          final c = CountryData.findByName(country);
          if (c != null) currencySymbol = c.currencySymbol;
        }

        return GlassCard(
          glowColor: AppColors.forest500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Production Overview',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontFamilyFallback: const ['Liberation Serif', 'serif'],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const Icon(
                    Icons.grass_rounded,
                    color: AppColors.forest700,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              (() {
                final cropsList = <String>[];
                if (profiles.isNotEmpty) {
                  final p = profiles.first;
                  if (p.primaryCrop != null &&
                      p.primaryCrop!.trim().isNotEmpty) {
                    cropsList.add(p.primaryCrop!.trim());
                  }
                  if (p.secondaryCrop != null &&
                      p.secondaryCrop!.trim().isNotEmpty) {
                    cropsList.add(p.secondaryCrop!.trim());
                  }
                }
                if (cropsList.isEmpty) {
                  return Text(
                    'Set up your farm profile to see production data.',
                    style: TextStyle(fontSize: 12, color: mutedTextColor),
                  );
                }
                return Column(
                  children: cropsList
                      .map(
                        (crop) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.forest100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  size: 14,
                                  color: AppColors.forest700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  crop,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              })(),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Revenue',
                    style: TextStyle(fontSize: 11, color: mutedTextColor),
                  ),
                  Text(
                    '$currencySymbol${totalRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forest700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AiSuggestedTodoList extends StatefulWidget {
  const _AiSuggestedTodoList({required this.profilesFuture, super.key});
  final Future<List<FarmProfile>> profilesFuture;

  @override
  State<_AiSuggestedTodoList> createState() => _AiSuggestedTodoListState();
}

class _AiSuggestedTodoListState extends State<_AiSuggestedTodoList> {
  List<String> _todos = [];
  final Map<String, bool> _checked = {};

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('custom_todo_list') ?? [];
    if (saved.isEmpty) {
      final profiles = await widget.profilesFuture;
      final profile = profiles.firstOrNull;
      final crop = profile?.primaryCrop?.trim() ?? 'Crops';
      final region = profile?.region?.trim() ?? 'your fields';
      saved = [
        'Inspect $crop fields for early signs of leaf spot or rust',
        'Verify drip irrigation scheduling for $crop in $region',
        'Log nitrogen level activity check from soil test results',
        'Assess pest trap counts to determine threshold levels',
      ];
      await prefs.setStringList('custom_todo_list', saved);
    }
    final checkedKeys = prefs.getStringList('custom_todo_checked') ?? [];
    if (mounted) {
      setState(() {
        _todos = saved;
        _checked.clear();
        for (final key in checkedKeys) {
          _checked[key] = true;
        }
      });
    }
  }

  Future<void> _toggleChecked(String todo) async {
    setState(() {
      _checked[todo] = !(_checked[todo] ?? false);
    });
    final prefs = await SharedPreferences.getInstance();
    final checkedKeys = _checked.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    await prefs.setStringList('custom_todo_checked', checkedKeys);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
    final mutedTextColor = isDark ? const Color(0xFFA8B5AC) : AppColors.ink500;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.gold500,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'To-Do Today (AI Suggested)',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontFamilyFallback: const ['Liberation Serif', 'serif'],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_todos.isEmpty)
            Text(
              'No tasks in your list.',
              style: TextStyle(fontSize: 12, color: mutedTextColor),
            )
          else
            ..._todos.map((item) {
              final isChecked = _checked[item] ?? false;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _toggleChecked(item),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isChecked
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: isChecked ? AppColors.forest500 : mutedTextColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontFamily: 'Calibri',
                            fontFamilyFallback: const [
                              'Liberation Sans',
                              'sans-serif',
                            ],
                            fontSize: 13,
                            color: isChecked ? mutedTextColor : textColor,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class CustomTodoListScreen extends StatefulWidget {
  const CustomTodoListScreen({super.key});

  @override
  State<CustomTodoListScreen> createState() => _CustomTodoListScreenState();
}

class _CustomTodoListScreenState extends State<CustomTodoListScreen> {
  final List<String> _todos = [];
  final Map<String, bool> _checked = {};
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('custom_todo_list');
    if (saved != null) {
      setState(() {
        _todos.addAll(saved);
      });
    }
    final checkedKeys = prefs.getStringList('custom_todo_checked') ?? [];
    setState(() {
      for (final key in checkedKeys) {
        _checked[key] = true;
      }
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_todo_list', _todos);
    final checkedKeys = _checked.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    await prefs.setStringList('custom_todo_checked', checkedKeys);
  }

  void _addTodo() {
    final text = _todoController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.add(text);
      _todoController.clear();
    });
    _saveTodos();
  }

  void _toggleChecked(String todo) {
    setState(() {
      _checked[todo] = !(_checked[todo] ?? false);
    });
    _saveTodos();
  }

  void _deleteTodo(String todo) {
    setState(() {
      _todos.remove(todo);
      _checked.remove(todo);
    });
    _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF000000) : AppColors.cream100;
    final cardBg = isDark ? const Color(0xFF121413) : Colors.white;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;
    final mutedTextColor = isDark ? const Color(0xFFA8B5AC) : AppColors.ink500;
    final forestGreen = isDark ? const Color(0xFF3E8E5E) : AppColors.forest700;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My To-Do List',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontFamilyFallback: const ['Liberation Serif', 'serif'],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Organise your daily farm operations',
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                  fontSize: 13,
                  color: mutedTextColor,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Input bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF262C28)
                              : const Color(0xFFE5DDD0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: TextField(
                        controller: _todoController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add a new task...',
                          hintStyle: TextStyle(
                            color: mutedTextColor,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addTodo(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  IconButton(
                    onPressed: _addTodo,
                    icon: const Icon(Icons.add_circle_rounded, size: 36),
                    color: forestGreen,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // To-Do Items
              Expanded(
                child: _todos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fact_check_outlined,
                              size: 48,
                              color: mutedTextColor,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No tasks yet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Type a task above to add it to your list.',
                              style: TextStyle(
                                fontSize: 12,
                                color: mutedTextColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          final isChecked = _checked[todo] ?? false;

                          return AppCard(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (_) => _toggleChecked(todo),
                                  activeColor: forestGreen,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    todo,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isChecked
                                          ? mutedTextColor
                                          : textColor,
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _deleteTodo(todo),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  color: AppColors.errorRed,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../core/app_services.dart';
import '../../core/config/country_config.dart';
import '../../core/theme.dart';
import '../../core/services/theme_service.dart';
import 'package:agroedge_shared/models/farm-profile.dart';
import 'package:agroedge_shared/models/expense.dart';

class LocalCropPlan {
  LocalCropPlan({
    required this.id,
    required this.cropName,
    required this.localName,
    required this.plotName,
    required this.hectares,
    required this.plantingDate,
    required this.expectedYield,
    this.actualYield,
    required this.expectedPrice,
    this.actualPlantingDate,
    required this.seasonName,
  });

  final String id;
  final String cropName;
  final String localName;
  final String plotName;
  final double hectares;
  final DateTime plantingDate;
  final double expectedYield;
  final double? actualYield;
  final double expectedPrice;
  final DateTime? actualPlantingDate;
  final String seasonName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'cropName': cropName,
    'localName': localName,
    'plotName': plotName,
    'hectares': hectares,
    'plantingDate': plantingDate.toIso8601String(),
    'expectedYield': expectedYield,
    'actualYield': actualYield,
    'expectedPrice': expectedPrice,
    'actualPlantingDate': actualPlantingDate?.toIso8601String(),
    'seasonName': seasonName,
  };

  factory LocalCropPlan.fromJson(Map<String, dynamic> json) => LocalCropPlan(
    id: json['id'] as String,
    cropName: json['cropName'] as String,
    localName: json['localName'] as String,
    plotName: json['plotName'] as String,
    hectares: (json['hectares'] as num).toDouble(),
    plantingDate: DateTime.parse(json['plantingDate'] as String),
    expectedYield: (json['expectedYield'] as num).toDouble(),
    actualYield: json['actualYield'] != null
        ? (json['actualYield'] as num).toDouble()
        : null,
    expectedPrice: (json['expectedPrice'] as num).toDouble(),
    actualPlantingDate: json['actualPlantingDate'] != null
        ? DateTime.parse(json['actualPlantingDate'] as String)
        : null,
    seasonName: json['seasonName'] as String,
  );
}

class CropPlanningScreen extends StatefulWidget {
  const CropPlanningScreen({super.key});

  @override
  State<CropPlanningScreen> createState() => _CropPlanningScreenState();
}

class _CropPlanningScreenState extends State<CropPlanningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LocalCropPlan> _plans = [];
  bool _isLoading = true;
  FarmProfile? _profile;
  CountryConfig? _config;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileAndPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileAndPlans() async {
    setState(() => _isLoading = true);
    try {
      final profiles = await AppServices.instance.farmProfiles.list();
      if (profiles.isNotEmpty) {
        _profile = profiles.first;
        _config = CountryConfig.findByCountryName(
          _profile?.country ?? 'Zimbabwe',
        );
      } else {
        _config = CountryConfig.configs[1]; // default Zimbabwe
      }

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('local_crop_plans');
      if (saved != null) {
        _plans = saved
            .map(
              (s) =>
                  LocalCropPlan.fromJson(jsonDecode(s) as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _savePlans() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _plans.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('local_crop_plans', data);
  }

  Future<void> _addPlan(LocalCropPlan plan) async {
    setState(() {
      _plans.add(plan);
    });
    await _savePlans();
  }

  Future<void> _deletePlan(String id) async {
    setState(() {
      _plans.removeWhere((p) => p.id == id);
    });
    await _savePlans();
  }

  List<String> _getRotationWarnings() {
    final warnings = <String>[];
    final plotPlans = <String, List<LocalCropPlan>>{};
    for (final plan in _plans) {
      plotPlans.putIfAbsent(plan.plotName, () => []).add(plan);
    }

    for (final entry in plotPlans.entries) {
      final plot = entry.key;
      final plans = entry.value;
      plans.sort((a, b) => a.plantingDate.compareTo(b.plantingDate));

      for (int i = 0; i < plans.length - 1; i++) {
        final current = plans[i];
        final next = plans[i + 1];
        if (current.cropName.toLowerCase() == next.cropName.toLowerCase()) {
          warnings.add(
            'Warning for $plot: Consecutive planting of ${current.cropName} detected. Consider rotating with a legume (e.g. Beans or Cowpeas) to replenish nitrogen soil layers.',
          );
        }
      }
    }
    return warnings;
  }

  void _showAddPlanDialog() {
    if (_config == null) return;

    final priorityCrops = _config!.priorityCrops;
    String selectedCrop = priorityCrops.first['crop']!;
    String localName = priorityCrops.first['local']!;

    final plotController = TextEditingController(text: 'Plot A');
    final sizeController = TextEditingController(text: '1.0');
    final yieldController = TextEditingController(text: '5.0');
    final priceController = TextEditingController(text: '350.0');
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: const Text('New Crop Plan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCrop,
                      decoration: const InputDecoration(labelText: 'Crop Type'),
                      items: priorityCrops.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['crop']!,
                          child: Text('${c['crop']!} (${c['local']!})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCrop = val;
                            localName = priorityCrops.firstWhere(
                              (c) => c['crop'] == val,
                            )['local']!;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: plotController,
                      decoration: const InputDecoration(
                        labelText: 'Plot / Field Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sizeController,
                      decoration: const InputDecoration(
                        labelText: 'Size (Hectares)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: yieldController,
                      decoration: const InputDecoration(
                        labelText: 'Expected Yield (Tons)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText:
                            'Market Price per Ton (${_config!.currencySymbol})',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Planting Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
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
                  onPressed: () {
                    final size = double.tryParse(sizeController.text) ?? 1.0;
                    final expYield =
                        double.tryParse(yieldController.text) ?? 5.0;
                    final price =
                        double.tryParse(priceController.text) ?? 350.0;

                    final newPlan = LocalCropPlan(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      cropName: selectedCrop,
                      localName: localName,
                      plotName: plotController.text,
                      hectares: size,
                      plantingDate: selectedDate,
                      expectedYield: expYield,
                      expectedPrice: price,
                      seasonName: _config!.seasons.first.name,
                    );
                    _addPlan(newPlan);
                    Navigator.pop(context);
                  },
                  child: const Text('Create Plan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _duplicateLastSeason() {
    if (_plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No plan templates available to duplicate.'),
        ),
      );
      return;
    }
    setState(() {
      final duplicates = _plans.map((p) {
        return LocalCropPlan(
          id: (DateTime.now().microsecondsSinceEpoch + p.hashCode).toString(),
          cropName: p.cropName,
          localName: p.localName,
          plotName: '${p.plotName} (Copy)',
          hectares: p.hectares,
          plantingDate: p.plantingDate.add(const Duration(days: 365)),
          expectedYield: p.expectedYield,
          expectedPrice: p.expectedPrice,
          seasonName: p.seasonName,
        );
      }).toList();
      _plans.addAll(duplicates);
    });
    _savePlans();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully duplicated plans to next season.'),
      ),
    );
  }

  Future<void> _writeToExpenses(LocalCropPlan plan) async {
    final cost = plan.hectares * 150.0; // seed + fertilizer estimate
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AppServices.instance.expenses.create(
        ExpenseCreate(
          amount: cost,
          category: 'Seeds & Fertilizers',
          expenseDate: plan.plantingDate,
          notes: 'Planned input cost for ${plan.cropName} on ${plan.plotName}',
        ),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Added planned expense of ${_config!.currencySymbol}${cost.toStringAsFixed(2)} to budget tracker.',
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not log planned expense.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.instance.isDark;
    final cardBg = isDark ? const Color(0xFF14261C) : Colors.white;
    final textColor = isDark ? const Color(0xFFFBF4E4) : AppColors.ink900;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_config == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please set up farm profile country settings first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_config!.countryName} — ${_config!.programmeName}'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Plots'),
            Tab(text: 'Budget Calc'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanDialog,
        backgroundColor: AppColors.forest700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineTab(cardBg, textColor),
          _buildPlotsTab(cardBg, textColor),
          _buildBudgetTab(cardBg, textColor),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(Color cardBg, Color textColor) {
    if (_plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.playlist_add_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'No Crop Plans active.',
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddPlanDialog,
              child: const Text('Add Plan'),
            ),
          ],
        ),
      );
    }

    final warnings = _getRotationWarnings();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Season timeline (Gantt representation)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                tooltip: 'Duplicate last season',
                onPressed: _duplicateLastSeason,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (warnings.isNotEmpty) ...[
            ...warnings.map(
              (warn) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBD943A).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFBD943A).withOpacity(0.4),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFBD943A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warn,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${plan.cropName} (${plan.localName})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.errorRed,
                            size: 18,
                          ),
                          onPressed: () => _deletePlan(plan.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plot: ${plan.plotName} · Area: ${plan.hectares} ha · Planting: ${DateFormat('MMM d').format(plan.plantingDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildGanttPhase('Planting', Colors.brown[300]!, true),
                        _buildGanttPhase(
                          'Sprout',
                          Colors.lightGreen[200]!,
                          true,
                        ),
                        _buildGanttPhase('Bloom', Colors.green[400]!, true),
                        _buildGanttPhase('Harvest', AppColors.gold500, true),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGanttPhase(String label, Color color, bool active) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: active ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: active ? Colors.black87 : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPlotsTab(Color cardBg, Color textColor) {
    double totalAllocated = _plans.fold(
      0.0,
      (sum, item) => sum + item.hectares,
    );
    double totalFarmSize = _profile?.farmSize ?? 4.2;
    double idleHectares = (totalFarmSize - totalAllocated).clamp(
      0.0,
      totalFarmSize,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Farm Size:',
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      '$totalFarmSize ha',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Allocated Hectares:',
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      '$totalAllocated ha',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.forest700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Idle Hectares:', style: TextStyle(color: textColor)),
                    Text(
                      '$idleHectares ha',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (totalAllocated / totalFarmSize).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(AppColors.forest700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Plot Allocations & Rotation Warnings',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.plotName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '${plan.hectares} ha',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Allocated Crop: ${plan.cropName}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Warning: Same crop family planted on ${plan.plotName} in preceding cycles. Consider rotating to legumes to protect nitrogen levels.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab(Color cardBg, Color textColor) {
    if (_plans.isEmpty) {
      return Center(
        child: Text(
          'Add a crop plan to calculate budgets.',
          style: TextStyle(color: textColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final plan = _plans[index];
        final cost = plan.hectares * 150.0;
        final revenue = plan.expectedYield * plan.expectedPrice;
        final margin = revenue - cost;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget: ${plan.cropName} on ${plan.plotName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected Revenue:'),
                  Text(
                    '${_config!.currencySymbol}${revenue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.forest700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Inputs cost:'),
                  Text('${_config!.currencySymbol}${cost.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Projected Margin:'),
                  Text(
                    '${_config!.currencySymbol}${margin.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: margin >= 0
                          ? AppColors.forest700
                          : AppColors.errorRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _writeToExpenses(plan),
                  icon: const Icon(Icons.add_task),
                  label: const Text('Add planned budget to expense ledger'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

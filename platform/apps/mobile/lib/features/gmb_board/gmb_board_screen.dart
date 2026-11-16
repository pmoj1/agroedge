import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agroedge_shared/models/farm-profile.dart';
import '../../core/app_services.dart';
import '../../core/design_system/app_card.dart';
import '../../core/design_system/app_states.dart';
import '../../core/theme.dart';

class GmbBoardScreen extends StatefulWidget {
  const GmbBoardScreen({super.key});

  @override
  State<GmbBoardScreen> createState() => _GmbBoardScreenState();
}

class _GmbBoardScreenState extends State<GmbBoardScreen> {
  late Future<List<FarmProfile>> _profilesFuture;
  final _calculatorWeightCtrl = TextEditingController();
  String _selectedCrop = 'Maize';
  double _calculatedPayout = 0.0;

  @override
  void initState() {
    super.initState();
    _profilesFuture = AppServices.instance.farmProfiles.list();
  }

  @override
  void dispose() {
    _calculatorWeightCtrl.dispose();
    super.dispose();
  }

  // Realistic seasonal price data for national marketing boards
  Map<String, dynamic> _getBoardData(String country) {
    switch (country) {
      case 'Zimbabwe':
        return {
          'agency': {
            'name': 'Grain Marketing Board (GMB)',
            'currency': 'USD',
            'symbol': r'$',
            'unit': 'tonne',
          },
          'crops': {
            'Maize': {'price': 390.0, 'status': 'Open'},
            'Soya Beans': {'price': 580.0, 'status': 'Open'},
            'Wheat': {'price': 440.0, 'status': 'Closed'},
            'Sorghum': {'price': 360.0, 'status': 'Open'},
            'Millet': {'price': 360.0, 'status': 'Open'},
          },
          'depots': [
            'Harare Aspindale',
            'Bulawayo Steelport',
            'Gweru Depot',
            'Masvingo Depot',
            'Mutare Depot',
          ],
          'requirements':
              'Moisture content must be below 12.5% for all white maize deliveries. Bags must be standard GMB weight.',
        };
      case 'Zambia':
        return {
          'agency': {
            'name': 'Food Reserve Agency (FRA)',
            'currency': 'ZMW',
            'symbol': 'K',
            'unit': '50kg bag',
          },
          'crops': {
            'Maize': {'price': 280.0, 'status': 'Open'},
            'Soya Beans': {'price': 350.0, 'status': 'Open'},
            'Wheat': {'price': 400.0, 'status': 'Closed'},
            'Sorghum': {'price': 240.0, 'status': 'Open'},
            'Groundnuts': {'price': 320.0, 'status': 'Open'},
          },
          'depots': [
            'Lusaka Main',
            'Copperbelt Depot',
            'Choma Depot',
            'Chipata Depot',
            'Kasama Depot',
          ],
          'requirements':
              'Deliveries must be packed in clean 50kg polypropylene bags. Moisture limit: 13.0%.',
        };
      case 'Kenya':
        return {
          'agency': {
            'name': 'National Cereals & Produce Board (NCPB)',
            'currency': 'KES',
            'symbol': 'KSh',
            'unit': '90kg bag',
          },
          'crops': {
            'Maize': {'price': 3200.0, 'status': 'Open'},
            'Beans': {'price': 8500.0, 'status': 'Open'},
            'Wheat': {'price': 4300.0, 'status': 'Closed'},
            'Rice': {'price': 7200.0, 'status': 'Open'},
            'Sorghum': {'price': 2800.0, 'status': 'Open'},
          },
          'depots': [
            'Nairobi Silos',
            'Mombasa Grain Silo',
            'Eldoret Depot',
            'Kisumu Depot',
            'Nakuru Depot',
          ],
          'requirements':
              'Moisture level maximum: 13.5%. Bring original national ID and farmer registration voucher.',
        };
      default:
        // Default JSE SAFEX / South Africa
        return {
          'agency': {
            'name': 'SAFEX Agricultural Markets Board',
            'currency': 'ZAR',
            'symbol': 'R',
            'unit': 'tonne',
          },
          'crops': {
            'Maize': {'price': 4200.0, 'status': 'Open'},
            'Wheat': {'price': 6100.0, 'status': 'Open'},
            'Soya Beans': {'price': 8300.0, 'status': 'Open'},
            'Sunflower': {'price': 9100.0, 'status': 'Closed'},
            'Sorghum': {'price': 3800.0, 'status': 'Open'},
          },
          'depots': [
            'Limpopo Silos',
            'Mpumalanga Grain Hub',
            'Free State Co-op',
            'North West Grain',
          ],
          'requirements':
              'Grading conforms to national SAGIS standards. Moisture maximum: 14.0%.',
        };
    }
  }

  void _calculate(Map<String, dynamic> boardData) {
    final weight = double.tryParse(_calculatorWeightCtrl.text.trim()) ?? 0.0;
    final crops = boardData['crops'] as Map<String, dynamic>;
    final selectedCropData = crops[_selectedCrop];
    if (selectedCropData != null) {
      final price = (selectedCropData['price'] as num).toDouble();
      setState(() {
        _calculatedPayout = weight * price;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<FarmProfile>>(
      future: _profilesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.forest700),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: AppErrorState(
              title: 'Marketing Board Offline',
              errorMessage: 'Could not load national marketing board stats.',
              onRetry: () => setState(() {
                _profilesFuture = AppServices.instance.farmProfiles.list();
              }),
            ),
          );
        }

        final profiles = snapshot.data ?? [];
        final profile = profiles.isNotEmpty ? profiles.first : null;
        final countryName = profile?.country ?? 'Zimbabwe';
        final board = _getBoardData(countryName);

        final agency = board['agency'] as Map<String, dynamic>;
        final crops = board['crops'] as Map<String, dynamic>;
        final depots = board['depots'] as List<String>;
        final requirements = board['requirements'] as String;

        final currencySymbol = agency['symbol'] as String;
        final unit = agency['unit'] as String;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _profilesFuture = AppServices.instance.farmProfiles.list();
            });
          },
          color: AppColors.forest700,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agency['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontFamilyFallback: ['Liberation Serif', 'serif'],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Official seasonal prices and crop delivery guidelines for $countryName',
                      style: const TextStyle(
                        fontFamily: 'Calibri',
                        fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                        fontSize: 12,
                        color: AppColors.ink500,
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Crop Price Table Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Seasonal Purchase Prices',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1),
                      },
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: Colors.grey.shade100,
                          width: 1,
                        ),
                      ),
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'CROP',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'PRICE / $unit',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'STATUS',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...crops.entries.map((entry) {
                          final cropName = entry.key;
                          final price = (entry.value['price'] as num)
                              .toDouble();
                          final status = entry.value['status'] as String;

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  cropName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink900,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  '$currencySymbol${NumberFormat.decimalPattern().format(price)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.forest700,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: status == 'Open'
                                        ? const Color(0xFFE2F0D9)
                                        : const Color(0xFFFCE4D6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: status == 'Open'
                                          ? AppColors.forest700
                                          : AppColors.clay400,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 2. Interactive Calculator
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          color: AppColors.forest700,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Expected Payout Calculator',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCrop,
                            decoration: const InputDecoration(
                              labelText: 'Crop',
                              border: OutlineInputBorder(),
                            ),
                            items: crops.keys.map((crop) {
                              return DropdownMenuItem(
                                value: crop,
                                child: Text(crop),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCrop = val;
                                  _calculate(board);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _calculatorWeightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Weight ($unit)',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) => _calculate(board),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cream100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimated Board Payout:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink900,
                            ),
                          ),
                          Text(
                            '$currencySymbol${NumberFormat.decimalPattern().format(_calculatedPayout)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forest700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 3. Delivery Guidelines
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.gold600),
                        SizedBox(width: 8),
                        Text(
                          'Depot Delivery Guidelines',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      requirements,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.ink500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'AUTHORIZED DELIVERY DEPOTS:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...depots.map(
                      (depot) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.forest700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              depot,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.ink900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }
}

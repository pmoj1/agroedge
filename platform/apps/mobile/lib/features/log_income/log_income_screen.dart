import 'package:agroedge_shared/models/income-record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api_client.dart';
import '../../core/app_services.dart';
import '../../core/design_system/app_button.dart';
import '../../core/design_system/app_card.dart';
import '../../core/design_system/app_states.dart';
import '../../core/services/gemini_service.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// Log Income: crop, buyer, date, price_per_unit, quantity_sold,
/// total_revenue -- maps directly to the income_records resource, per
/// the build brief ("same pattern" as activities/expenses).
class LogIncomeScreen extends StatefulWidget {
  const LogIncomeScreen({super.key});

  @override
  State<LogIncomeScreen> createState() => _LogIncomeScreenState();
}

class _LogIncomeScreenState extends State<LogIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _buyerController = TextEditingController();
  final _pricePerUnitController = TextEditingController();
  final _quantitySoldController = TextEditingController();
  final _totalRevenueController = TextEditingController();
  final _aiInputController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  bool _isAiLoading = false;
  String? _errorMessage;
  bool _shouldShake = false;
  List<String> _farmCrops = [];

  @override
  void initState() {
    super.initState();
    _pricePerUnitController.addListener(_calculateTotal);
    _quantitySoldController.addListener(_calculateTotal);
    _loadCrops();
  }

  @override
  void dispose() {
    _pricePerUnitController.removeListener(_calculateTotal);
    _quantitySoldController.removeListener(_calculateTotal);
    _cropController.dispose();
    _buyerController.dispose();
    _pricePerUnitController.dispose();
    _quantitySoldController.dispose();
    _totalRevenueController.dispose();
    _aiInputController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final price = double.tryParse(_pricePerUnitController.text.trim()) ?? 0.0;
    final qty = double.tryParse(_quantitySoldController.text.trim()) ?? 0.0;
    if (price > 0 && qty > 0) {
      final total = price * qty;
      final formattedTotal = total.toStringAsFixed(
        total == total.roundToDouble() ? 0 : 2,
      );
      // Only set text if it's different to avoid cursor jump issues
      if (_totalRevenueController.text != formattedTotal) {
        _totalRevenueController.value = TextEditingValue(
          text: formattedTotal,
          selection: TextSelection.collapsed(offset: formattedTotal.length),
        );
      }
    }
  }

  Future<void> _loadCrops() async {
    try {
      final profiles = await AppServices.instance.farmProfiles.list();
      if (profiles.isNotEmpty) {
        final p = profiles.first;
        setState(() {
          _farmCrops = [
            p.primaryCrop,
            p.secondaryCrop,
          ].whereType<String>().toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _runAiAssist() async {
    final text = _aiInputController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isAiLoading = true);
    try {
      final result = await GeminiService.instance.processEntry(
        text,
        'income',
        farmCrops: _farmCrops.join(', '),
      );
      if (result.isNotEmpty && mounted) {
        setState(() {
          if (result.containsKey('crop')) {
            _cropController.text = result['crop']!;
          }
          if (result.containsKey('buyer')) {
            _buyerController.text = result['buyer']!;
          }
          if (result.containsKey('date')) {
            final parsedDate = DateTime.tryParse(result['date']!);
            if (parsedDate != null) _date = parsedDate;
          }
          if (result.containsKey('price_per_unit')) {
            _pricePerUnitController.text = result['price_per_unit']!;
          }
          if (result.containsKey('quantity_sold')) {
            _quantitySoldController.text = result['quantity_sold']!;
          }
          if (result.containsKey('total_revenue')) {
            _totalRevenueController.text = result['total_revenue']!;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Form auto-filled by AI! Please review before saving.',
            ),
            backgroundColor: AppColors.forest700,
          ),
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isAiLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.forest700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.ink900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  String? _validateOptionalNumber(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim()) == null
        ? l10n.validationMustBeNumber
        : null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      setState(() => _shouldShake = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _shouldShake = false);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AppServices.instance.incomeRecords.create(
        IncomeRecordCreate(
          incomeDate: _date,
          crop: _cropController.text.trim().isEmpty
              ? null
              : _cropController.text.trim(),
          buyer: _buyerController.text.trim().isEmpty
              ? null
              : _buyerController.text.trim(),
          pricePerUnit: double.tryParse(_pricePerUnitController.text.trim()),
          quantitySold: double.tryParse(_quantitySoldController.text.trim()),
          totalRevenue: double.tryParse(_totalRevenueController.text.trim()),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.logIncomeSavedConfirmation),
            backgroundColor: AppColors.forest700,
          ),
        );
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
      _triggerErrorFeedback();
    } catch (_) {
      setState(() => _errorMessage = l10n.commonSomethingWentWrong);
      _triggerErrorFeedback();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _triggerErrorFeedback() {
    setState(() => _shouldShake = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _shouldShake = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(l10n.logIncomeTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppValidationShake(
                shouldShake: _shouldShake,
                child: AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (GeminiService.instance.isAvailable) ...[
                          Card(
                            color: AppColors.forest100,
                            elevation: 0,
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: AppColors.forest700.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: AppColors.forest700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      const Text(
                                        'AI Smart Fill',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.forest700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (_isAiLoading)
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.forest700,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  const Text(
                                    'Describe your sales in plain text (e.g. "sold 10 tons of maize to Grain Marketing Board for \$300 per ton today") to auto-fill this form.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.ink500,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _aiInputController,
                                          decoration: const InputDecoration(
                                            hintText: 'Type income details...',
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.forest700,
                                          minimumSize: const Size(60, 36),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        onPressed: _isAiLoading
                                            ? null
                                            : _runAiAssist,
                                        child: const Text(
                                          'Fill',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (_farmCrops.isNotEmpty) ...[
                          const Text(
                            'Quick Crop Select:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _farmCrops.map((crop) {
                              final isSelected =
                                  _cropController.text.trim().toLowerCase() ==
                                  crop.trim().toLowerCase();
                              return ChoiceChip(
                                label: Text(crop),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _cropController.text = crop;
                                    });
                                  }
                                },
                                selectedColor: AppColors.forest100,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.forest700
                                      : AppColors.ink900,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        TextFormField(
                          controller: _cropController,
                          decoration: InputDecoration(
                            labelText: l10n.logIncomeCropLabel,
                            helperText: l10n.commonOptional,
                            prefixIcon: const Icon(
                              Icons.grass_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _buyerController,
                          decoration: InputDecoration(
                            labelText: l10n.logIncomeBuyerLabel,
                            helperText: l10n.commonOptional,
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.logIncomeDateLabel,
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat.yMMMd().format(_date),
                                  style: textTheme.bodyMedium,
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.ink500,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _pricePerUnitController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: l10n.logIncomePricePerUnitLabel,
                                  helperText: l10n.commonOptional,
                                  prefixIcon: const Icon(
                                    Icons.price_change_outlined,
                                    size: 20,
                                  ),
                                ),
                                validator: (value) =>
                                    _validateOptionalNumber(value, l10n),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextFormField(
                                controller: _quantitySoldController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  labelText: l10n.logIncomeQuantitySoldLabel,
                                  helperText: l10n.commonOptional,
                                  prefixIcon: const Icon(
                                    Icons.scale_outlined,
                                    size: 20,
                                  ),
                                ),
                                validator: (value) =>
                                    _validateOptionalNumber(value, l10n),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _totalRevenueController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.logIncomeTotalRevenueLabel,
                            helperText:
                                'Auto-calculated from price and quantity',
                            prefixIcon: const Icon(
                              Icons.monetization_on_outlined,
                              size: 20,
                            ),
                          ),
                          validator: (value) =>
                              _validateOptionalNumber(value, l10n),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 16,
                                color: AppColors.errorRed,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.errorRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: l10n.commonSave,
                          onPressed: _isSubmitting ? null : _submit,
                          isLoading: _isSubmitting,
                          variant: AppButtonVariant.filled,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

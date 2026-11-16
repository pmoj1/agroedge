import 'package:agroedge_shared/models/income-record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api_client.dart';
import '../../core/app_services.dart';
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
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cropController.dispose();
    _buyerController.dispose();
    _pricePerUnitController.dispose();
    _quantitySoldController.dispose();
    _totalRevenueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String? _validateOptionalNumber(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim()) == null ? l10n.validationMustBeNumber : null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AppServices.instance.incomeRecords.create(
        IncomeRecordCreate(
          incomeDate: _date,
          crop: _cropController.text.trim().isEmpty ? null : _cropController.text.trim(),
          buyer: _buyerController.text.trim().isEmpty ? null : _buyerController.text.trim(),
          pricePerUnit: double.tryParse(_pricePerUnitController.text.trim()),
          quantitySold: double.tryParse(_quantitySoldController.text.trim()),
          totalRevenue: double.tryParse(_totalRevenueController.text.trim()),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.logIncomeSavedConfirmation)));
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.logIncomeTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _cropController,
                      decoration: InputDecoration(
                        labelText: l10n.logIncomeCropLabel,
                        helperText: l10n.commonOptional,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _buyerController,
                      decoration: InputDecoration(
                        labelText: l10n.logIncomeBuyerLabel,
                        helperText: l10n.commonOptional,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: l10n.logIncomeDateLabel),
                        child: Text(DateFormat.yMMMd().format(_date)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _pricePerUnitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.logIncomePricePerUnitLabel,
                        helperText: l10n.commonOptional,
                      ),
                      validator: (value) => _validateOptionalNumber(value, l10n),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _quantitySoldController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.logIncomeQuantitySoldLabel,
                        helperText: l10n.commonOptional,
                      ),
                      validator: (value) => _validateOptionalNumber(value, l10n),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _totalRevenueController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.logIncomeTotalRevenueLabel,
                        helperText: l10n.commonOptional,
                      ),
                      validator: (value) => _validateOptionalNumber(value, l10n),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.errorPlaceholder)),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l10n.commonSave),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

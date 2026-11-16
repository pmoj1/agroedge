import 'package:agroedge_shared/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api_client.dart';
import '../../core/app_services.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// Log Expense: amount, category, date, notes -- maps directly to the
/// expenses resource, per the build brief ("same pattern" as activities).
class LogExpenseScreen extends StatefulWidget {
  const LogExpenseScreen({super.key});

  @override
  State<LogExpenseScreen> createState() => _LogExpenseScreenState();
}

class _LogExpenseScreenState extends State<LogExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
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

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AppServices.instance.expenses.create(
        ExpenseCreate(
          amount: double.parse(_amountController.text.trim()),
          expenseDate: _date,
          category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.logExpenseSavedConfirmation)));
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
      appBar: AppBar(title: Text(l10n.logExpenseTitle)),
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
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.logExpenseAmountLabel),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.validationRequired;
                        return double.tryParse(value.trim()) == null ? l10n.validationMustBeNumber : null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: l10n.logExpenseCategoryLabel,
                        helperText: l10n.commonOptional,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: l10n.logExpenseDateLabel),
                        child: Text(DateFormat.yMMMd().format(_date)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.logExpenseNotesLabel,
                        helperText: l10n.commonOptional,
                      ),
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

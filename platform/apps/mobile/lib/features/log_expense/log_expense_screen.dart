import 'package:agroedge_shared/models/expense.dart';
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
    _loadCrops();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _aiInputController.dispose();
    super.dispose();
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
        'expense',
        farmCrops: _farmCrops.join(', '),
      );
      if (result.isNotEmpty && mounted) {
        setState(() {
          if (result.containsKey('amount')) {
            _amountController.text = result['amount']!;
          }
          if (result.containsKey('category')) {
            _categoryController.text = result['category']!;
          }
          if (result.containsKey('date')) {
            final parsedDate = DateTime.tryParse(result['date']!);
            if (parsedDate != null) _date = parsedDate;
          }
          if (result.containsKey('notes')) {
            _notesController.text = result['notes']!;
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
      await AppServices.instance.expenses.create(
        ExpenseCreate(
          amount: double.parse(_amountController.text.trim()),
          expenseDate: _date,
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.logExpenseSavedConfirmation),
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
      appBar: AppBar(title: Text(l10n.logExpenseTitle)),
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
                                    'Describe your expense in plain text (e.g. "spent \$45 on fertilizer for corn yesterday") to auto-fill this form.',
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
                                            hintText: 'Type expense details...',
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
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.logExpenseAmountLabel,
                            prefixIcon: const Icon(
                              Icons.payments_outlined,
                              size: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.validationRequired;
                            }
                            return double.tryParse(value.trim()) == null
                                ? l10n.validationMustBeNumber
                                : null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: l10n.logExpenseCategoryLabel,
                            helperText: l10n.commonOptional,
                            prefixIcon: const Icon(
                              Icons.category_outlined,
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
                              labelText: l10n.logExpenseDateLabel,
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
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: l10n.logExpenseNotesLabel,
                            helperText: l10n.commonOptional,
                            prefixIcon: const Icon(
                              Icons.notes_outlined,
                              size: 20,
                            ),
                          ),
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

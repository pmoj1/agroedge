import 'package:agroedge_shared/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api_client.dart';
import '../../core/app_services.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// Log Activity: activity_type, crop, date, notes, optional
/// yield_quantity/yield_unit -- maps directly to the activities resource,
/// per the build brief.
class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({super.key});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityTypeController = TextEditingController();
  final _cropController = TextEditingController();
  final _notesController = TextEditingController();
  final _yieldQuantityController = TextEditingController();
  final _yieldUnitController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _activityTypeController.dispose();
    _cropController.dispose();
    _notesController.dispose();
    _yieldQuantityController.dispose();
    _yieldUnitController.dispose();
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
      await AppServices.instance.activities.create(
        ActivityCreate(
          activityType: _activityTypeController.text.trim(),
          activityDate: _date,
          crop: _cropController.text.trim().isEmpty ? null : _cropController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          yieldQuantity: double.tryParse(_yieldQuantityController.text.trim()),
          yieldUnit: _yieldUnitController.text.trim().isEmpty ? null : _yieldUnitController.text.trim(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.logActivitySavedConfirmation)));
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
      appBar: AppBar(title: Text(l10n.logActivityTitle)),
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
                      controller: _activityTypeController,
                      decoration: InputDecoration(labelText: l10n.logActivityTypeLabel),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? l10n.validationRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _cropController,
                      decoration: InputDecoration(
                        labelText: l10n.logActivityCropLabel,
                        helperText: l10n.commonOptional,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: l10n.logActivityDateLabel),
                        child: Text(DateFormat.yMMMd().format(_date)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.logActivityNotesLabel,
                        helperText: l10n.commonOptional,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _yieldQuantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.logActivityYieldQuantityLabel,
                        helperText: l10n.commonOptional,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return double.tryParse(value.trim()) == null ? l10n.validationMustBeNumber : null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _yieldUnitController,
                      decoration: InputDecoration(
                        labelText: l10n.logActivityYieldUnitLabel,
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

import 'package:agroedge_shared/models/farm-profile.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_services.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// One-time farm setup, shown after sign-in when the farmer has no
/// farm_profile yet. Farm name, size, primary crop, region -- per the
/// build brief. Nothing else: "Don't build settings, profile editing
/// beyond initial setup."
class FarmSetupScreen extends StatefulWidget {
  const FarmSetupScreen({required this.onSaved, super.key});

  final VoidCallback onSaved;

  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _primaryCropController = TextEditingController();
  final _regionController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _farmNameController.dispose();
    _farmSizeController.dispose();
    _primaryCropController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AppServices.instance.farmProfiles.create(
        FarmProfileCreate(
          farmName: _farmNameController.text.trim(),
          farmSize: double.tryParse(_farmSizeController.text.trim()),
          primaryCrop: _primaryCropController.text.trim(),
          region: _regionController.text.trim(),
        ),
      );
      widget.onSaved();
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
      appBar: AppBar(title: Text(l10n.farmSetupTitle)),
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
                    Text(l10n.farmSetupIntro, style: const TextStyle(color: AppColors.ink500)),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _farmNameController,
                      decoration: InputDecoration(labelText: l10n.farmSetupFarmNameLabel),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? l10n.farmSetupRequiredField : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _farmSizeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.farmSetupFarmSizeLabel,
                        helperText: l10n.commonOptional,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return double.tryParse(value.trim()) == null ? l10n.validationMustBeNumber : null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _primaryCropController,
                      decoration: InputDecoration(labelText: l10n.farmSetupPrimaryCropLabel),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? l10n.farmSetupRequiredField : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _regionController,
                      decoration: InputDecoration(labelText: l10n.farmSetupRegionLabel),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? l10n.farmSetupRequiredField : null,
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
                          : Text(l10n.farmSetupSaveButton),
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

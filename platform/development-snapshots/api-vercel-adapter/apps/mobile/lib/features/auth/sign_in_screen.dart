import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// Simple Supabase Auth email/password sign-in for the 3 known pilot
/// farmers. No social login, no magic links -- see build brief.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // AuthGate rebuilds automatically on the auth state change stream.
    } on AuthException {
      setState(() => _errorMessage = l10n.signInInvalidCredentials);
    } catch (_) {
      setState(() => _errorMessage = l10n.signInGenericError);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.signInTitle,
                      style: const TextStyle(
                        fontSize: AppFontSizes.title,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forest900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(labelText: l10n.signInEmailLabel),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? l10n.validationRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(labelText: l10n.signInPasswordLabel),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? l10n.validationRequired : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.errorPlaceholder),
                      ),
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
                          : Text(l10n.signInButton),
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

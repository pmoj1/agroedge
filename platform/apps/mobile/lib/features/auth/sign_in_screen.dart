import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/design_system/app_button.dart';
import '../../core/design_system/app_card.dart';
import '../../core/design_system/app_states.dart';
import '../../core/design_system/app_typography.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// Immersive full-screen dark-gradient sign-in.
/// A glass morphism card floats over the animated savanna gradient.
/// All auth business logic is preserved exactly.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _shouldShake = false;
  bool _obscurePassword = true;

  // Background gradient shift animation
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      _triggerErrorFeedback();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // AuthGate rebuilds automatically on stream change — no nav needed.
    } on AuthException catch (e) {
      setState(
        () => _errorMessage = e.message.isNotEmpty
            ? l10n.signInInvalidCredentials
            : l10n.signInGenericError,
      );
      _triggerErrorFeedback();
    } catch (_) {
      setState(() => _errorMessage = l10n.signInGenericError);
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

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnim,
        builder: (context, _) {
          // Slow gradient colour shift between deep forest tones
          final t = _bgAnim.value;
          final topColor = Color.lerp(
            AppColors.forest900,
            const Color(0xFF0A2518),
            t,
          )!;
          final bottomColor = Color.lerp(
            AppColors.forest700,
            const Color(0xFF0F3020),
            t,
          )!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [topColor, bottomColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxxl,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AppValidationShake(
                      shouldShake: _shouldShake,
                      child: AppCard(
                        variant: AppCardVariant.glass,
                        borderRadius: 20,
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo
                              Center(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.gold500.withValues(
                                          alpha: 0.3,
                                        ),
                                        AppColors.forest700.withValues(
                                          alpha: 0.5,
                                        ),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: AppColors.gold500.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.eco_rounded,
                                    color: AppColors.gold500,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Title
                              AppTypography.title(
                                l10n.signInTitle,
                                color: Colors.white,
                                align: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              const AppTypography.caption(
                                'AgroEdge — Temo Letlotlo',
                                color: Colors.white70,
                                align: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: AppColors.gold500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.06,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.gold500,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.errorRed,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.errorRed,
                                      width: 2,
                                    ),
                                  ),
                                  errorStyle: const TextStyle(
                                    color: AppColors.errorRed,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: const [AutofillHints.password],
                                style: const TextStyle(color: Colors.white),
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                    color: AppColors.gold500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.06,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.gold500,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.errorRed,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.errorRed,
                                      width: 2,
                                    ),
                                  ),
                                  errorStyle: const TextStyle(
                                    color: AppColors.errorRed,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  return null;
                                },
                              ),

                              // Error message
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
                                        style: const TextStyle(
                                          color: AppColors.errorRed,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xl),

                              // CTA
                              AppButton(
                                label: l10n.signInButton,
                                onPressed: _isSubmitting ? null : _submit,
                                isLoading: _isSubmitting,
                                variant: AppButtonVariant.gradient,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Footer
                              AppTypography.caption(
                                'Secure · Offline-capable · Setswana / Shona',
                                align: TextAlign.center,
                                color: Colors.white.withValues(alpha: 0.35),
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
        },
      ),
    );
  }
}

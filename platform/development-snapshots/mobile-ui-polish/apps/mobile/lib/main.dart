import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'core/theme.dart';
import 'features/auth/auth_gate.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  runApp(const AgroEdgeMobileApp());
}

/// Entry point for the farmer-facing pilot build (Flutter Web). See
/// apps/mobile/CLAUDE.md for the full offline-first, multilingual product
/// this pilot intentionally narrows down from -- 3 known pilot farmers,
/// connectivity assumed, English only.
class AgroEdgeMobileApp extends StatelessWidget {
  const AgroEdgeMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Env.isConfigured ? const AuthGate() : const _MissingConfigScreen(),
    );
  }
}

class _MissingConfigScreen extends StatelessWidget {
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Missing SUPABASE_URL / SUPABASE_ANON_KEY.\n'
            'Run with --dart-define-from-file, see apps/mobile/README.md.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

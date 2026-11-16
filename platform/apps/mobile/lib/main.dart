import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'core/services/locale_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme.dart';
import 'core/components/error_boundary.dart';
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

  // Init language preference from SharedPreferences
  await LocaleService.instance.init();
  // Init theme preference
  await ThemeService.instance.init();

  runApp(const AgroEdgeMobileApp());
}

class AgroEdgeMobileApp extends StatefulWidget {
  const AgroEdgeMobileApp({super.key});

  @override
  State<AgroEdgeMobileApp> createState() => _AgroEdgeMobileAppState();
}

class _AgroEdgeMobileAppState extends State<AgroEdgeMobileApp> {
  @override
  void initState() {
    super.initState();
    LocaleService.instance.addListener(_onLocaleChange);
    ThemeService.instance.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    LocaleService.instance.removeListener(_onLocaleChange);
    ThemeService.instance.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onLocaleChange() => setState(() {});
  void _onThemeChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(LocaleService.instance.locale.languageCode),
      // Trigger Netlify Re-deploy
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'AgroEdge',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(isDark: false),
      darkTheme: buildAppTheme(isDark: true),
      themeMode: ThemeService.instance.themeMode,
      locale: () {
        final current = LocaleService.instance.locale;
        if (current.languageCode == 'tn' || current.languageCode == 'nd') {
          return const Locale('en');
        }
        return current;
      }(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('pt'),
        Locale('sn'),
        Locale('sw'),
        Locale('tn'),
        Locale('nd'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('en');
        if (locale.languageCode == 'tn' || locale.languageCode == 'nd') {
          return const Locale('en');
        }
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
      builder: (context, child) =>
          ErrorBoundary(child: child ?? const SizedBox.shrink()),
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

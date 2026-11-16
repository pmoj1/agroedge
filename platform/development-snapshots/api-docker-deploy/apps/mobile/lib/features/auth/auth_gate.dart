import 'package:agroedge_shared/models/farm-profile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_services.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../farm_setup/farm_setup_screen.dart';
import '../home/home_screen.dart';
import 'sign_in_screen.dart';

/// Routes between sign-in, one-time farm setup, and the home screen,
/// per the build brief: "After sign-in, if no farm_profile exists for
/// this user, route to a one-time farm setup screen."
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const SignInScreen();
        }
        return const _FarmProfileGate();
      },
    );
  }
}

class _FarmProfileGate extends StatefulWidget {
  const _FarmProfileGate();

  @override
  State<_FarmProfileGate> createState() => _FarmProfileGateState();
}

class _FarmProfileGateState extends State<_FarmProfileGate> {
  late Future<List<FarmProfile>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppServices.instance.farmProfiles.list();
  }

  void _recheck() {
    setState(() {
      _future = AppServices.instance.farmProfiles.list();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<FarmProfile>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonSomethingWentWrong),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(onPressed: _recheck, child: Text(l10n.commonRetry)),
                ],
              ),
            ),
          );
        }
        final profiles = snapshot.data ?? const [];
        if (profiles.isEmpty) {
          return FarmSetupScreen(onSaved: _recheck);
        }
        return const HomeScreen();
      },
    );
  }
}

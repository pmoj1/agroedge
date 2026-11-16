import 'package:flutter/material.dart';

import 'features/programme_overview/programme_overview_screen.dart';

void main() {
  runApp(const AgroEdgeDashboardApp());
}

/// Entry point for the institutional dashboard (Flutter Web). Root
/// CLAUDE.md and apps/CLAUDE.md govern; this screen is the only one built
/// so far and it is a static N=3 layout — see
/// apps/dashboard/docs/programme-overview.md.
class AgroEdgeDashboardApp extends StatelessWidget {
  const AgroEdgeDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroEdge — Programme Overview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      home: const Scaffold(body: ProgrammeOverviewScreen()),
    );
  }
}

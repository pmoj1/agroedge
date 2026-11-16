import 'package:flutter/material.dart';

import 'core/navigation/dashboard_shell.dart';

void main() {
  runApp(const AgroEdgeDashboardApp());
}

/// Entry point for the institutional dashboard (Flutter Web). Root
/// CLAUDE.md and apps/CLAUDE.md govern. Two screens are built so far --
/// Programme Overview (static N=3 layout, see
/// apps/dashboard/docs/programme-overview.md) and Subsidy Targeting --
/// reachable via the tab switcher in DashboardShell.
class AgroEdgeDashboardApp extends StatelessWidget {
  const AgroEdgeDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroEdge — Institutional Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      home: const DashboardShell(),
    );
  }
}

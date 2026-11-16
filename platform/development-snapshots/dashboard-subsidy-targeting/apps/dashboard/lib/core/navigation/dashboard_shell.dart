import 'package:flutter/material.dart';

import '../../features/programme_overview/programme_overview_screen.dart';
import '../../features/subsidy_targeting/subsidy_targeting_screen.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

/// Minimal screen switcher so more than one core view (apps/dashboard/CLAUDE.md
/// build order) can be reached in one running app. Not a router -- there is
/// no deep linking or URL state yet. Add a real router when a third screen
/// makes tab-switching insufficient.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  static const _tabs = ['Programme Overview', 'Subsidy Targeting'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _NavBar(
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            onSelected: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                ProgrammeOverviewScreen(),
                SubsidyTargetingScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.forest900,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            _NavTab(
              label: tabs[i],
              isSelected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.gold500 : const Color(0x00000000),
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.mastheadMeta.copyWith(
            color: isSelected ? AppColors.cream100 : AppColors.ink500,
          ),
        ),
      ),
    );
  }
}

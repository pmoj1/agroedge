import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// The four primary actions (log activity/expense/income, ask AI) as a
/// tappable card grid instead of floating pill buttons -- icon-forward,
/// with ripple + a subtle press-down scale for tactile feedback.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key, required this.actions});

  final List<HomeQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.3,
      children: [
        for (final action in actions)
          _ActionCard(icon: action.icon, label: action.label, onPressed: action.onPressed),
      ],
    );
  }
}

class HomeQuickAction {
  const HomeQuickAction({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.forest700, shape: BoxShape.circle),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.label,
                  style: const TextStyle(fontSize: AppFontSizes.small, fontWeight: FontWeight.w600, color: AppColors.ink900),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

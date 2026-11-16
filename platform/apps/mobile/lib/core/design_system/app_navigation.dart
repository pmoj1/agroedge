import 'package:flutter/material.dart';
import '../theme.dart';

class AppNavigationItem {
  const AppNavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 64.0 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14261C) : AppColors.cream100,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE5DDD0),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : AppColors.forest900.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = index == currentIndex;

            return Expanded(
              child: _BottomNavItem(
                item: item,
                isActive: isActive,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  const _BottomNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final AppNavigationItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    if (widget.isActive) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _BottomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _ctrl.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF3E8E5E) : AppColors.forest700;
    final inactiveColor = isDark ? const Color(0xFFA8B5AC) : AppColors.ink500;
    final color = widget.isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Icon(
                widget.isActive ? widget.item.activeIcon : widget.item.icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 4.0),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontFamily: 'Calibri',
                fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                fontSize: 10,
                fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w600,
                color: color,
                letterSpacing: 0.2,
              ),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}

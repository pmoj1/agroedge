import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class AppNavigationItem {
  const AppNavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.items,
    required this.currentRoute,
    required this.onItemSelected,
    this.isCollapsed = false,
    super.key,
  });

  final List<AppNavigationItem> items;
  final String currentRoute;
  final ValueChanged<String> onItemSelected;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isCollapsed ? 72.0 : 260.0,
      decoration: const BoxDecoration(
        color: AppColors.forest900,
        border: Border(
          right: BorderSide(
            color: Color(0xFF163C29),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Logo area
          Container(
            height: 72.0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(
                  Icons.eco,
                  color: AppColors.gold500,
                  size: 28,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: AppSpacing.md),
                  const Text(
                    'AgroEdge',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontFamilyFallback: ['Liberation Serif', 'serif'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Color(0xFF163C29), height: 1),
          const SizedBox(height: AppSpacing.md),

          // Nav items list
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = item.route == currentRoute;

                return _SidebarItem(
                  item: item,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  onTap: () => onItemSelected(item.route),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  final AppNavigationItem item;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.gold500;
    final defaultColor = Colors.white.withValues(alpha: 0.65);
    const hoverColor = Colors.white;

    final color = widget.isActive
        ? activeColor
        : (_isHovered ? hoverColor : defaultColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.white.withValues(alpha: 0.06)
                : (_isHovered
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Sliding/fade indicator on the left side
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: 0,
                top: widget.isActive ? 12.0 : 24.0,
                bottom: widget.isActive ? 12.0 : 24.0,
                width: 3.0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: widget.isActive ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gold500,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      widget.item.icon,
                      color: color,
                      size: 20,
                    ),
                    if (!widget.isCollapsed) ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontFamily: 'Calibri',
                            fontFamilyFallback: const [
                              'Liberation Sans',
                              'sans-serif'
                            ],
                            fontSize: 14,
                            fontWeight: widget.isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: color,
                          ),
                          child: Text(
                            widget.item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

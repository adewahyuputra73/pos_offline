import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Which nav item is currently active.
enum NavItem { dashboard, products, categories, settings }

/// Fixed-width (256 dp) navigation drawer — mirrors the HTML `<aside>`.
///
/// On narrow screens (< 1024 dp) this is wrapped in a Flutter [Drawer];
/// on wide screens it sits inline in the [Row] layout.
class SidebarWidget extends StatelessWidget {
  final NavItem selected;
  final ValueChanged<NavItem> onSelected;

  const SidebarWidget({
    super.key,
    this.selected = NavItem.dashboard,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      height: double.infinity,
      color: DC.stone100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand logo ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
            child: Text(
              'BARISTA POS',
              style: manrope(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: DC.stone900,
                letterSpacing: -0.8,
              ),
            ),
          ),

          // ── Primary nav ────────────────────────────────────────────────────
          _NavTile(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'DASHBOARD',
            selected: selected == NavItem.dashboard,
            onTap: () => onSelected(NavItem.dashboard),
          ),
          _NavTile(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            label: 'PRODUCTS',
            selected: selected == NavItem.products,
            onTap: () => onSelected(NavItem.products),
          ),
          _NavTile(
            icon: Icons.category_outlined,
            activeIcon: Icons.category_rounded,
            label: 'CATEGORIES',
            selected: selected == NavItem.categories,
            onTap: () => onSelected(NavItem.categories),
          ),

          const Spacer(),

          // ── Bottom nav ─────────────────────────────────────────────────────
          _NavTile(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'SETTINGS',
            selected: selected == NavItem.settings,
            onTap: () => onSelected(NavItem.settings),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          hoverColor: DC.stone200.withValues(alpha: 0.5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  size: 20,
                  color: selected ? DC.stone900 : DC.stone500,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: selected ? DC.stone900 : DC.stone500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

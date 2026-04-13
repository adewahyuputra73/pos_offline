import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

enum NavItem { dashboard, orders, settings }

/// Fixed 256-dp sidebar — mirrors the HTML `<aside class="w-64 fixed ...">`.
///
/// Background: stone-100 (#F5F5F4)
/// Active item: white card with subtle shadow
/// Inactive items: stone-500 text, hover stone-200/50
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
          // ── BARISTA POS brand ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
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

          // ── Primary nav items ──────────────────────────────────────────────
          _NavTile(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'DASHBOARD',
            selected: selected == NavItem.dashboard,
            onTap: () => onSelected(NavItem.dashboard),
          ),
          _NavTile(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'ORDERS',
            selected: selected == NavItem.orders,
            onTap: () => onSelected(NavItem.orders),
          ),

          const Spacer(),

          // ── Settings pinned at bottom ──────────────────────────────────────
          _NavTile(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'SETTINGS',
            selected: selected == NavItem.settings,
            onTap: () => onSelected(NavItem.settings),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
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
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // HTML: mx-4 (horizontal margin 16)
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            // HTML: px-4 py-3
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Active: bg-white shadow-sm | Hover inactive: bg-stone-200/50
              color: widget.selected
                  ? Colors.white
                  : _hovered
                      ? DC.stone200.withValues(alpha: 0.5)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // HTML: gap-3
                Icon(
                  widget.selected ? widget.activeIcon : widget.icon,
                  size: 22,
                  color: widget.selected ? DC.stone900 : DC.stone500,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: manrope(
                    // HTML: text-sm font-medium tracking-wide uppercase
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: widget.selected ? DC.stone900 : DC.stone500,
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

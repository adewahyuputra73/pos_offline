import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/state/app_state.dart';
import '../theme/dashboard_colors.dart';

enum NavItem { dashboard, orders, shift, transactions, inventory, hpp, settings }

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
    final hasActiveShift = context.watch<AppState>().hasActiveShift;

    return Container(
      width: 256,
      color: DC.stone100,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── BARISTA POS brand ────────────────────────────────────────────
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

            // ── Scrollable nav items ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    // ── SHIFT — dengan badge aktif ───────────────────────────
                    _NavTile(
                      icon: Icons.schedule_outlined,
                      activeIcon: Icons.schedule_rounded,
                      label: 'SHIFT',
                      selected: selected == NavItem.shift,
                      onTap: () => onSelected(NavItem.shift),
                      badge: hasActiveShift
                          ? _ActiveBadge()
                          : null,
                    ),
                    _NavTile(
                      icon: Icons.history_edu_outlined,
                      activeIcon: Icons.history_edu_rounded,
                      label: 'RIWAYAT TRANSAKSI',
                      selected: selected == NavItem.transactions,
                      onTap: () => onSelected(NavItem.transactions),
                    ),
                    _NavTile(
                      icon: Icons.kitchen_outlined,
                      activeIcon: Icons.kitchen_rounded,
                      label: 'BAHAN BAKU',
                      selected: selected == NavItem.inventory,
                      onTap: () => onSelected(NavItem.inventory),
                    ),
                    _NavTile(
                      icon: Icons.analytics_outlined,
                      activeIcon: Icons.analytics_rounded,
                      label: 'LAPORAN HPP',
                      selected: selected == NavItem.hpp,
                      onTap: () => onSelected(NavItem.hpp),
                    ),
                  ],
                ),
              ),
            ),

            // ── Divider ──────────────────────────────────────────────────────
            Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: DC.stone200,
            ),

            // ── Settings pinned at bottom ────────────────────────────────────
            _NavTile(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: 'SETTINGS',
              selected: selected == NavItem.settings,
              onTap: () => onSelected(NavItem.settings),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Small green dot shown next to SHIFT when a shift is active.
class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF4ADE80),
        shape: BoxShape.circle,
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
  final Widget? badge;

  const _NavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
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
                Expanded(
                  child: Text(
                    widget.label,
                    style: manrope(
                      // HTML: text-sm font-medium tracking-wide uppercase
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: widget.selected ? DC.stone900 : DC.stone500,
                    ),
                  ),
                ),
                if (widget.badge != null) ...[
                  const SizedBox(width: 8),
                  widget.badge!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/state/app_state.dart';
import '../theme/dashboard_colors.dart';

/// Sticky top header — mirrors `<header class="bg-stone-50 px-8 py-6 ...">`.
///
/// [leading] is set to a hamburger icon on narrow screens.
class TopBarWidget extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget? leading;

  const TopBarWidget({
    super.key,
    this.title = 'Coffee House Dashboard',
    this.titleWidget,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 600;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 32,
            vertical: 20,
          ),
          color: DC.stone50,
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],

              // HTML: text-2xl font-semibold tracking-tight
              Expanded(
                child: titleWidget ?? Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: manrope(
                    fontSize: compact ? 18 : 24,
                    fontWeight: FontWeight.w600,
                    color: DC.stone900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // HTML: gap-6 between profile chip and bell
              _ProfileChip(compact: compact),
              const SizedBox(width: 12),
              _NotifButton(),
            ],
          ),
        );
      },
    );
  }
}

/// `<div class="flex items-center gap-3 px-4 py-2 rounded-full bg-surface-container-low">`
class _ProfileChip extends StatelessWidget {
  final bool compact;
  const _ProfileChip({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cashierName = state.hasActiveShift
        ? state.activeShift!.cashierName
        : 'User';
    final initials = cashierName.length >= 2
        ? cashierName.substring(0, 2).toUpperCase()
        : cashierName.toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar circle with initials
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: state.hasActiveShift ? DC.primaryContainer : DC.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: state.hasActiveShift ? DC.onPrimaryContainer : DC.onSurfaceVariant,
              ),
            ),
          ),
          // Hide name on compact (mobile) to prevent overflow
          if (!compact) ...[
            const SizedBox(width: 12),
            Text(
              cashierName,
              style: manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DC.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// `<button class="w-10 h-10 rounded-full ...text-stone-500 hover:bg-stone-200/50">`
class _NotifButton extends StatefulWidget {
  @override
  State<_NotifButton> createState() => _NotifButtonState();
}

class _NotifButtonState extends State<_NotifButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered
                ? DC.stone200.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 22,
            color: DC.stone500,
          ),
        ),
      ),
    );
  }
}

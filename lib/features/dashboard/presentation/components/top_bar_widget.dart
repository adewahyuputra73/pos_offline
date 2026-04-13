import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Sticky top header — mirrors `<header class="bg-stone-50 px-8 py-6 ...">`.
///
/// [leading] is set to a hamburger icon on narrow screens.
class TopBarWidget extends StatelessWidget {
  final String title;
  final Widget? leading;

  const TopBarWidget({
    super.key,
    this.title = 'Coffee House Dashboard',
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // HTML: py-6 → 24 top/bottom; px-8 → 32 left/right
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: DC.stone50,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],

          // HTML: text-2xl font-semibold tracking-tight
          Expanded(
            child: Text(
              title,
              style: manrope(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: DC.stone900,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // HTML: gap-6 between profile chip and bell
          _ProfileChip(),
          const SizedBox(width: 24),
          _NotifButton(),
        ],
      ),
    );
  }
}

/// `<div class="flex items-center gap-3 px-4 py-2 rounded-full bg-surface-container-low">`
class _ProfileChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // HTML: bg-surface-container-low (#f2f4f4)
        color: DC.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar — HTML: w-8 h-8 rounded-full object-cover
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuD0CQfV3xLuDuVWGh1_BHFRfiKDDXQhgXHB6ISQw8iFrkIrz4OX1o6ddhqMTw_z3k1-x3TMPqNM0njMRV9rFvGooJzGuqXx8v5IgY6Vg-iTxWUXhEx-9lCLKyVsS3fw_HVxScWjnbuAT9pdEZHcNVkVLVIYucWFvPd0OSl-Tv-dngSDK2kVp64MLJi4pqp7qb23e7NttmrDqhy-E_rz97A3MnjpsvtDdU8rg9Rsi8sSoU6VgwJAoo6tQgFnWS1Hga4KeBND8bThdK96',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: DC.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'AR',
                  style: manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DC.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // HTML: text-sm font-medium text-on-surface-variant
          Text(
            'Alex Rivera',
            style: manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DC.onSurfaceVariant,
            ),
          ),
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

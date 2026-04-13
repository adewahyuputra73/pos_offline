import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Sticky top app-bar — mirrors the HTML `<header>`.
///
/// [leading] is passed by the parent page on narrow screens (hamburger icon).
/// On wide screens [leading] is null and the title takes full flex space.
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
      height: 80,
      color: DC.stone50,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Optional hamburger for narrow layout
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],

          // Page title
          Expanded(
            child: Text(
              title,
              style: manrope(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: DC.stone900,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Profile chip
          _ProfileChip(),
          const SizedBox(width: 16),

          // Notification button
          _IconBtn(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar — falls back to an initials placeholder on error
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuD0CQfV3xLuDuVWGh1_BHFRfiKDDXQhgXHB6ISQw8iFrkIrz4OX1o6ddhqMTw_z3k1-x3TMPqNM0njMRV9rFvGooJzGuqXx8v5IgY6Vg-iTxWUXhEx-9lCLKyVsS3fw_HVxScWjnbuAT9pdEZHcNVkVLVIYucWFvPd0OSl-Tv-dngSDK2kVp64MLJi4pqp7qb23e7NttmrDqhy-E_rz97A3MnjpsvtDdU8rg9Rsi8sSoU6VgwJAoo6tQgFnWS1Hga4KeBND8bThdK96',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 30,
                height: 30,
                color: DC.primaryContainer,
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
          const SizedBox(width: 10),
          Text(
            'Alex Rivera',
            style: manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DC.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: DC.stone500),
        ),
      ),
    );
  }
}

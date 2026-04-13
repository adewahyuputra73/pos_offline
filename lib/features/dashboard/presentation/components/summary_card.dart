import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// `<div class="bg-surface-container-lowest p-8 rounded-xl shadow-[0_4px_20px_rgba(45,37,20,0.04)]">`
///
/// White card with ambient brown shadow. [subtitle] slot for trend/info row.
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final Widget subtitle;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // HTML: p-8 = 32dp all sides
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest, // #ffffff
        borderRadius: BorderRadius.circular(12), // rounded-xl = 0.75rem
        boxShadow: [
          // HTML: shadow-[0_4px_20px_rgba(45,37,20,0.04)]
          BoxShadow(
            color: const Color(0xFF2D2514).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HTML: flex items-start justify-between mb-6
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // HTML: p-3 rounded-lg bg-primary-container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              // HTML: text-xs font-bold tracking-widest text-on-surface-variant/60 uppercase
              Text(
                label,
                style: manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),

          // HTML: mb-6 → space-y-1 below
          const SizedBox(height: 24),

          // HTML: text-4xl font-extrabold text-[#2d2514] tracking-tight
          Text(
            value,
            style: manrope(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: DC.deepBrown,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          subtitle,
        ],
      ),
    );
  }
}

// ── Subtitle helpers ──────────────────────────────────────────────────────────

/// `<div class="flex items-center gap-1 text-tertiary font-medium text-sm">`
/// Used for trend (green/olive) and warning (error) rows.
class TrendSubtitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const TrendSubtitle({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// `<div class="flex items-center gap-1 text-on-surface-variant/70 font-medium text-sm">`
class InfoSubtitle extends StatelessWidget {
  final String text;
  final IconData icon;

  const InfoSubtitle({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16,
            color: DC.onSurfaceVariant.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DC.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

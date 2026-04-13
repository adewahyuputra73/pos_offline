import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Reusable bento-style summary card (Today's Revenue / Transactions /
/// Inventory Items). Mirrors the three `<div>` cards at the top of the HTML.
///
/// The [subtitle] slot accepts any widget so each card can display a
/// different flavour of metadata (trend %, sync time, low-stock warning).
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  /// Rendered below the main value — pass one of the subtitle helpers below.
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: DC.deepBrown.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + label row ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Text(
                label,
                style: manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Big number ─────────────────────────────────────────────────────
          Text(
            value,
            style: manrope(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: DC.deepBrown,
              letterSpacing: -1.5,
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

/// "+12.5% from yesterday" style row.
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
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// "Last sync: 2m ago" or any icon + muted text row.
class InfoSubtitle extends StatelessWidget {
  final String text;
  final IconData icon;

  const InfoSubtitle({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: DC.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: DC.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

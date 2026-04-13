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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 200;
        final double pad = compact ? 16 : 32;

        return Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: DC.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 8 : 12),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: compact ? 18 : 22),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: manrope(
                        fontSize: compact ? 8 : 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: compact ? 0.8 : 1.6,
                        color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),

              SizedBox(height: compact ? 12 : 24),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: manrope(
                    fontSize: compact ? 24 : 36,
                    fontWeight: FontWeight.w800,
                    color: DC.deepBrown,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              subtitle,
            ],
          ),
        );
      },
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

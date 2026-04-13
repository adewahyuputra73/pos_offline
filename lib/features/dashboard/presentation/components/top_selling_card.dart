import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// `<div class="bg-surface-container-lowest rounded-xl p-8 shadow-[...]">`
class TopSellingCard extends StatelessWidget {
  const TopSellingCard({super.key});

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // HTML: flex items-center justify-between mb-6
          Row(
            children: [
              // HTML: text-sm font-extrabold text-[#2d2514] uppercase tracking-wider
              Expanded(
                child: Text(
                  'TOP SELLING ITEMS',
                  style: manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: DC.deepBrown,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // HTML: text-xs text-on-surface-variant font-medium
              Text(
                'This Week',
                style: manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: DC.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // HTML: flex gap-4
          Row(
            children: const [
              Expanded(
                child: _ItemTile(
                  category: 'Coffee',
                  name: 'Oat Latte',
                  sold: '422 Sold',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _ItemTile(
                  category: 'Pastry',
                  name: 'Pain au Choc',
                  sold: '184 Sold',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String category;
  final String name;
  final String sold;

  const _ItemTile({
    required this.category,
    required this.name,
    required this.sold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // HTML: flex-1 p-4 rounded-xl bg-surface-container-low
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HTML: text-[10px] font-bold text-on-surface-variant/50 uppercase tracking-tighter mb-1
          Text(
            category.toUpperCase(),
            style: manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: DC.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          // HTML: text-lg font-bold text-[#2d2514]
          Text(
            name,
            style: manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DC.deepBrown,
            ),
          ),
          const SizedBox(height: 2),
          // HTML: text-xs font-medium text-tertiary
          Text(
            sold,
            style: manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DC.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

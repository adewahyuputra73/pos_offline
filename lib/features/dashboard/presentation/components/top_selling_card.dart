import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

// ── Dummy data ────────────────────────────────────────────────────────────────

class _TopItem {
  final String category;
  final String name;
  final String soldCount;

  const _TopItem({
    required this.category,
    required this.name,
    required this.soldCount,
  });
}

const _kTopItems = <_TopItem>[
  _TopItem(category: 'Coffee', name: 'Oat Latte', soldCount: '422 Sold'),
  _TopItem(category: 'Pastry', name: 'Pain au Choc', soldCount: '184 Sold'),
];

// ── Widget ────────────────────────────────────────────────────────────────────

/// "Top Selling Items" card — mirrors the right half of the bottom section.
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
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
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
          const SizedBox(height: 20),

          // ── Item grid (2 columns) ─────────────────────────────────────────
          Row(
            children: _kTopItems
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: item == _kTopItems.last ? 0 : 16,
                      ),
                      child: _TopItemTile(item: item),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TopItemTile extends StatelessWidget {
  final _TopItem item;

  const _TopItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.category.toUpperCase(),
            style: manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: DC.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.name,
            style: manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DC.deepBrown,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.soldCount,
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

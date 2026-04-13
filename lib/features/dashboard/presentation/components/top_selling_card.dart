import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// `<div class="bg-surface-container-lowest rounded-xl p-8 shadow-[...]">`
class TopSellingCard extends StatelessWidget {
  const TopSellingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 300;
        final double pad = compact ? 16 : 32;

        return Container(
          padding: EdgeInsets.all(pad),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'TOP SELLING ITEMS',
                      style: manrope(
                        fontSize: compact ? 10 : 12,
                        fontWeight: FontWeight.w800,
                        color: DC.deepBrown,
                        letterSpacing: compact ? 0.8 : 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'This Week',
                    style: manrope(
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.w500,
                      color: DC.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 12 : 24),

              Row(
                children: [
                  Expanded(
                    child: _ItemTile(
                      category: 'Coffee',
                      name: 'Oat Latte',
                      sold: '422 Sold',
                      compact: compact,
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 16),
                  Expanded(
                    child: _ItemTile(
                      category: 'Pastry',
                      name: 'Pain au Choc',
                      sold: '184 Sold',
                      compact: compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String category;
  final String name;
  final String sold;
  final bool compact;

  const _ItemTile({
    required this.category,
    required this.name,
    required this.sold,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 16),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.toUpperCase(),
            style: manrope(
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: DC.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: manrope(
              fontSize: compact ? 13 : 16,
              fontWeight: FontWeight.w700,
              color: DC.deepBrown,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sold,
            style: manrope(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: DC.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

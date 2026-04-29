import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/state/app_state.dart';
import '../theme/dashboard_colors.dart';

/// Top selling items card — aggregates real transaction data.
class TopSellingCard extends StatelessWidget {
  const TopSellingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final topItems = _getTopSelling(state, limit: 2);

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
                      'PRODUK TERLARIS',
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
                    'Semua Waktu',
                    style: manrope(
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.w500,
                      color: DC.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 12 : 24),
              if (topItems.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Belum ada data penjualan',
                      style: manrope(
                        fontSize: 13,
                        color: DC.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: topItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < topItems.length - 1 ? (compact ? 8 : 16) : 0),
                        child: _ItemTile(
                          name: item.name,
                          sold: '${item.totalQty} Terjual',
                          compact: compact,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  List<_TopItem> _getTopSelling(AppState state, {int limit = 2}) {
    final Map<String, _TopItem> map = {};
    for (final tx in state.transactions) {
      for (final item in tx.items) {
        final existing = map[item.productId];
        if (existing != null) {
          map[item.productId] = _TopItem(
            name: item.productName,
            totalQty: existing.totalQty + item.quantity,
          );
        } else {
          map[item.productId] = _TopItem(
            name: item.productName,
            totalQty: item.quantity,
          );
        }
      }
    }
    final sorted = map.values.toList()..sort((a, b) => b.totalQty.compareTo(a.totalQty));
    return sorted.take(limit).toList();
  }
}

class _TopItem {
  final String name;
  final int totalQty;
  const _TopItem({required this.name, required this.totalQty});
}

class _ItemTile extends StatelessWidget {
  final String name;
  final String sold;
  final bool compact;

  const _ItemTile({required this.name, required this.sold, this.compact = false});

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
            name,
            style: manrope(fontSize: compact ? 13 : 16, fontWeight: FontWeight.w700, color: DC.deepBrown),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(sold, style: manrope(fontSize: compact ? 10 : 12, fontWeight: FontWeight.w500, color: DC.tertiary)),
        ],
      ),
    );
  }
}

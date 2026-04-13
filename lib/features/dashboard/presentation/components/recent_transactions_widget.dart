import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

// ── Dummy data model ──────────────────────────────────────────────────────────

class _TxItem {
  final String name;
  final String orderId;
  final String time;
  final String amount;
  final bool isPaid; // false = Refund
  final String imageUrl;

  const _TxItem({
    required this.name,
    required this.orderId,
    required this.time,
    required this.amount,
    required this.isPaid,
    required this.imageUrl,
  });
}

const _kTransactions = <_TxItem>[
  _TxItem(
    name: 'Flat White + Oat',
    orderId: '#4092',
    time: '2:45 PM',
    amount: '\$5.50',
    isPaid: true,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuACsHZ1bakS1glU62jrYz1dZQAlgRyZfXNWQC6PbqoHjC5lYOtzblCr81MYVr8uUwn03Z5cguCAMW9p7aB0gisIx5GP2RQ5Muytlh4BSSr5Ws-n3teKKBBCdbQCzGFVwQH2VgTW6DHRb6-CBNOmDfymi_od0eeI0h_cJlVYD5GzD7Aq-u-sd9uxyxgusXPXLz8lo3y72_kTxLIPABjlODDsy2pIl0nF2-rrSTfgpClbD7sSrDLaClDBrF1IFaYuNJcIoR4QJHdgZ7FD',
  ),
  _TxItem(
    name: 'Almond Croissant',
    orderId: '#4091',
    time: '2:32 PM',
    amount: '\$4.25',
    isPaid: true,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAjKCP5y3zJTDjAwR0nptJjEjnYpQIaEZpHEAHVMhseGXFsUylKz30o0R8pVG58F3oz97-y7EdX_Qw9_oV0bQc0EyIopfftSdwtz8_Q1Pm2S62F-9Yn5I4SluvdKmijPSPnK_H3g16Qip652f75PGc1jrKsF159ADUL_B2p-6FWwFiLN5_fasE84e-UjtELxPdc7q-7jESQdSG2fpt1gj5QQkv4l5Vb_Ek-aZ0-BrfkhBT41Pa0LCbRa-CVe2zE2hafJeaCpu3A6xwD',
  ),
  _TxItem(
    name: 'Double Espresso',
    orderId: '#4090',
    time: '2:15 PM',
    amount: '\$3.50',
    isPaid: false,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBM61ehyB56TZSBBsCLKDInahN2pVVzq-GHpuvwdXwIOdw3iLisLNCfmWrU4GERXbEz057CNiFfX-8ab4bv_EMUr4NoBya2-f0YX_mxLRd9qf15CsF58fMXWJh4rupONDY89mrJbvsraWMwNFvDaDedUKR2H0SR8fgQflc_sUK7a2MJuUhDMf3GosMOu5Y3v4uKAigjFwfOL9091UlHGfK4smUk6DlAptSqxwSf3vgaNNJYGQwI2LDKc0kYAPInwTWufVyAYqwN9eIZ',
  ),
];

// ── Main widget ───────────────────────────────────────────────────────────────

/// Recent Sales panel — mirrors the `lg:col-span-1` section in the HTML.
///
/// Contains a scrollable transaction list and a "Create New Order" CTA button.
class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

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
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                'Recent Sales',
                style: manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: DC.deepBrown,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View All',
                  style: manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DC.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: DC.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Transaction list ─────────────────────────────────────────────────
          ..._kTransactions
              .map((tx) => _TransactionRow(item: tx))
              .toList(),

          const SizedBox(height: 28),

          // ── CTA button ───────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: DC.primary,
                foregroundColor: DC.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Create New Order'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row widget ────────────────────────────────────────────────────────────────

class _TransactionRow extends StatelessWidget {
  final _TxItem item;

  const _TransactionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Opacity(
        // Refund items appear slightly faded, matching the HTML `opacity-70`
        opacity: item.isPaid ? 1.0 : 0.7,
        child: Row(
          children: [
            // Product thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: DC.surfaceContainerLow,
                  child: Icon(
                    Icons.coffee_outlined,
                    color: DC.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name + order meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: DC.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.orderId} • ${item.time}',
                    style: manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Amount + status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount,
                  style: manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: DC.deepBrown,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusBadge(isPaid: item.isPaid),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPaid;

  const _StatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? DC.tertiaryContainer : DC.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPaid ? 'PAID' : 'REFUND',
        style: manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: isPaid
              ? DC.tertiary
              : DC.onSurfaceVariant.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

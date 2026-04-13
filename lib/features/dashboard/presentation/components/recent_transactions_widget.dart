import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

// ── Dummy data ────────────────────────────────────────────────────────────────

class _Tx {
  final String name;
  final String meta; // "#4092 • 2:45 PM"
  final String amount;
  final bool isPaid;
  final String imageUrl;

  const _Tx({
    required this.name,
    required this.meta,
    required this.amount,
    required this.isPaid,
    required this.imageUrl,
  });
}

const _kTx = <_Tx>[
  _Tx(
    name: 'Flat White + Oat',
    meta: '#4092 • 2:45 PM',
    amount: '\$5.50',
    isPaid: true,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuACsHZ1bakS1glU62jrYz1dZQAlgRyZfXNWQC6PbqoHjC5lYOtzblCr81MYVr8uUwn03Z5cguCAMW9p7aB0gisIx5GP2RQ5Muytlh4BSSr5Ws-n3teKKBBCdbQCzGFVwQH2VgTW6DHRb6-CBNOmDfymi_od0eeI0h_cJlVYD5GzD7Aq-u-sd9uxyxgusXPXLz8lo3y72_kTxLIPABjlODDsy2pIl0nF2-rrSTfgpClbD7sSrDLaClDBrF1IFaYuNJcIoR4QJHdgZ7FD',
  ),
  _Tx(
    name: 'Almond Croissant',
    meta: '#4091 • 2:32 PM',
    amount: '\$4.25',
    isPaid: true,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAjKCP5y3zJTDjAwR0nptJjEjnYpQIaEZpHEAHVMhseGXFsUylKz30o0R8pVG58F3oz97-y7EdX_Qw9_oV0bQc0EyIopfftSdwtz8_Q1Pm2S62F-9Yn5I4SluvdKmijPSPnK_H3g16Qip652f75PGc1jrKsF159ADUL_B2p-6FWwFiLN5_fasE84e-UjtELxPdc7q-7jESQdSG2fpt1gj5QQkv4l5Vb_Ek-aZ0-BrfkhBT41Pa0LCbRa-CVe2zE2hafJeaCpu3A6xwD',
  ),
  _Tx(
    name: 'Double Espresso',
    meta: '#4090 • 2:15 PM',
    amount: '\$3.50',
    isPaid: false, // Refund — HTML: opacity-70
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBM61ehyB56TZSBBsCLKDInahN2pVVzq-GHpuvwdXwIOdw3iLisLNCfmWrU4GERXbEz057CNiFfX-8ab4bv_EMUr4NoBya2-f0YX_mxLRd9qf15CsF58fMXWJh4rupONDY89mrJbvsraWMwNFvDaDedUKR2H0SR8fgQflc_sUK7a2MJuUhDMf3GosMOu5Y3v4uKAigjFwfOL9091UlHGfK4smUk6DlAptSqxwSf3vgaNNJYGQwI2LDKc0kYAPInwTWufVyAYqwN9eIZ',
  ),
];

// ── Widget ────────────────────────────────────────────────────────────────────

/// `<div class="bg-surface-container-lowest p-8 rounded-xl ... flex flex-col">`
class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 360;
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
                      'Recent Sales',
                      style: manrope(
                        fontSize: compact ? 16 : 20,
                        fontWeight: FontWeight.w700,
                        color: DC.deepBrown,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'View All',
                      style: manrope(
                        fontSize: compact ? 11 : 13,
                        fontWeight: FontWeight.w700,
                        color: DC.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: DC.primary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: compact ? 16 : 24),

              ..._kTx.map(
                (tx) => Padding(
                  padding: EdgeInsets.only(bottom: compact ? 12 : 20),
                  child: _TxRow(tx: tx),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DC.primary,
                    foregroundColor: DC.onPrimary,
                    elevation: 0,
                    shadowColor: DC.primary.withValues(alpha: 0.2),
                    padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: manrope(
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  child: const Text('Create New Order'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Transaction row ───────────────────────────────────────────────────────────

class _TxRow extends StatelessWidget {
  final _Tx tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    // HTML: opacity-70 on refund item
    return Opacity(
      opacity: tx.isPaid ? 1.0 : 0.7,
      child: Row(
        children: [
          // HTML: w-12 h-12 rounded-xl bg-surface-container-low overflow-hidden
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              tx.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                color: DC.surfaceContainerLow,
                child: Icon(Icons.coffee_outlined,
                    color: DC.onSurfaceVariant, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HTML: text-sm font-bold text-on-surface
                Text(
                  tx.name,
                  style: manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DC.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                // HTML: text-[11px] font-medium text-on-surface-variant/60
                Text(
                  tx.meta,
                  style: manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Amount + badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // HTML: text-sm font-extrabold text-[#2d2514]
              Text(
                tx.amount,
                style: manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: DC.deepBrown,
                ),
              ),
              const SizedBox(height: 4),
              _StatusBadge(isPaid: tx.isPaid),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        // Paid: bg-tertiary-container | Refund: bg-surface-container-high
        color: isPaid ? DC.tertiaryContainer : DC.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Refund',
        style: manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: isPaid
              ? DC.tertiary
              : DC.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/transaction.dart';
import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

/// Recent transactions card — reads real data from [AppState].
class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recent = state.transactions.take(5).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 360;
        final double pad = compact ? 16 : 32;
        final bool hasBoundedHeight = constraints.maxHeight.isFinite;

        Widget transactionContent;
        if (recent.isEmpty) {
          transactionContent = _EmptyState(compact: compact);
        } else if (hasBoundedHeight) {
          // In bounded context, make it scrollable
          transactionContent = Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: recent.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(bottom: compact ? 12 : 20),
                child: _TxRow(tx: recent[index]),
              ),
            ),
          );
        } else {
          // In unbounded context, show inline
          transactionContent = Column(
            children: recent.map(
              (tx) => Padding(
                padding: EdgeInsets.only(bottom: compact ? 12 : 20),
                child: _TxRow(tx: tx),
              ),
            ).toList(),
          );
        }

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
            mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(
                'Penjualan Terbaru',
                style: manrope(
                  fontSize: compact ? 16 : 20,
                  fontWeight: FontWeight.w700,
                  color: DC.deepBrown,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: compact ? 16 : 24),
              transactionContent,
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool compact;
  const _EmptyState({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 36, color: DC.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(
              'Belum ada transaksi',
              style: manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DC.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final TransactionRecord tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCash = tx.paymentMethod == PaymentMethod.cash;
    final itemNames = tx.items.map((i) => i.productName).join(', ');

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: DC.surfaceContainerLow,
          ),
          child: Icon(
            isCash ? Icons.payments_outlined : Icons.qr_code_2_outlined,
            color: DC.onSurfaceVariant,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemNames.isEmpty ? '${tx.items.length} item' : itemNames,
                style: manrope(fontSize: 13, fontWeight: FontWeight.w700, color: DC.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${formatTime(tx.createdAt)} • ${isCash ? "Tunai" : "QRIS"}',
                style: manrope(fontSize: 11, fontWeight: FontWeight.w500, color: DC.onSurfaceVariant.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatRupiah(tx.total),
              style: manrope(fontSize: 13, fontWeight: FontWeight.w800, color: DC.deepBrown),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DC.tertiaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isCash ? 'Tunai' : 'QRIS',
                style: manrope(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: DC.tertiary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

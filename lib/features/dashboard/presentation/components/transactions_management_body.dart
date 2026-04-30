import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/transaction.dart';
import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';
import '../pages/invoice_page.dart';

class TransactionsManagementBody extends StatefulWidget {
  final Widget? leading;
  const TransactionsManagementBody({super.key, this.leading});

  @override
  State<TransactionsManagementBody> createState() => _TransactionsManagementBodyState();
}

class _TransactionsManagementBodyState extends State<TransactionsManagementBody> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Reverse list to show newest first, then filter
    final reversedTransactions = state.transactions.reversed.toList();
    final filtered = reversedTransactions.where((t) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return t.id.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // ── Header & Search ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: DC.surfaceContainerLowest,
            border: Border(
              bottom: BorderSide(
                color: DC.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 16),
              ],
              Text(
                'Riwayat Transaksi',
                style: manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: DC.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Search field
              SizedBox(
                width: 280,
                height: 44,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Cari ID Transaksi...',
                    hintStyle: manrope(
                      fontSize: 14,
                      color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: DC.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── List ─────────────────────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _TransactionCard(record: filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DC.surfaceContainerHigh,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: DC.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tidak ada transaksi yang cocok'
                : 'Belum ada transaksi',
            style: manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DC.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Coba gunakan kata kunci ID yang lain'
                : 'Transaksi akan muncul di sini setelah pelanggan membayar.',
            style: manrope(
              fontSize: 14,
              color: DC.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionRecord record;
  const _TransactionCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DC.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${record.id}',
                    style: manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: DC.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDateFull(record.createdAt),
                    style: manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: DC.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: record.paymentMethod == PaymentMethod.qris
                      ? DC.primary.withValues(alpha: 0.1)
                      : DC.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  paymentMethodToString(record.paymentMethod).toUpperCase(),
                  style: manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: record.paymentMethod == PaymentMethod.qris
                        ? DC.primaryFixedDim
                        : DC.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${record.items.length} Item',
                style: manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DC.onSurfaceVariant,
                ),
              ),
              Text(
                formatRupiah(record.total),
                style: manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DC.primaryFixedDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InvoicePage(record: record),
                  ),
                );
              },
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Lihat & Cetak Struk'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DC.onSurface,
                side: BorderSide(color: DC.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

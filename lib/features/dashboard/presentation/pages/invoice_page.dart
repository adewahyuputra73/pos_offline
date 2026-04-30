import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:border_po/models/transaction.dart';
import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

class InvoicePage extends StatelessWidget {
  final TransactionRecord record;

  const InvoicePage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final storeProfile = state.storeProfile;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: DC.background,
      appBar: AppBar(
        backgroundColor: DC.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DC.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Invoice',
          style: manrope(fontWeight: FontWeight.w800, color: DC.onSurface),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menyiapkan dokumen untuk dicetak...')),
                );
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selesai!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.print_rounded, size: 18),
              label: Text(
                isMobile ? 'Cetak' : 'Cetak / Simpan PDF',
                style: manrope(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: DC.primary,
                foregroundColor: DC.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 40,
          vertical: 24,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: DC.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: DC.onSurface.withValues(alpha: 0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                _buildHeader(isMobile, storeProfile),

                // ── Content ──
                Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Info
                      _buildInvoiceInfo(isMobile),

                      const SizedBox(height: 28),

                      // Items Table
                      _buildItemsTable(isMobile),

                      const SizedBox(height: 24),

                      // Totals Section
                      _buildTotalsSection(isMobile, storeProfile),

                      const SizedBox(height: 28),

                      // Footer Note
                      _buildFooterNote(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, storeProfile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DC.primary.withValues(alpha: 0.06),
            DC.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          bottom: BorderSide(color: DC.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceTitle(),
                const SizedBox(height: 16),
                _buildStoreInfo(storeProfile),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceTitle(),
                _buildStoreInfo(storeProfile),
              ],
            ),
    );
  }

  Widget _buildInvoiceTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DC.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 22, color: DC.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'INVOICE',
              style: manrope(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: DC.onSurface,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: DC.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#${record.id.toUpperCase()}',
            style: manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: DC.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfo(storeProfile) {
    final storeName = storeProfile.storeName.isNotEmpty ? storeProfile.storeName : 'Toko Saya';
    final address = storeProfile.address.isNotEmpty ? storeProfile.address : '';
    final phone = storeProfile.phone.isNotEmpty ? storeProfile.phone : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          storeName.toUpperCase(),
          style: manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: DC.onSurface,
          ),
        ),
        if (address.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            address,
            textAlign: TextAlign.right,
            style: manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DC.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
        if (phone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            phone,
            textAlign: TextAlign.right,
            style: manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DC.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceInfo(bool isMobile) {
    final paymentLabel = record.paymentMethod == PaymentMethod.cash ? 'Tunai' : 'QRIS';
    final hasCashier = record.cashierName.isNotEmpty;
    final items = [
      _InfoChip(
        icon: Icons.calendar_today_rounded,
        label: 'Tanggal',
        value: formatDateShort(record.createdAt),
      ),
      _InfoChip(
        icon: Icons.access_time_rounded,
        label: 'Waktu',
        value: formatTime(record.createdAt),
      ),
      _InfoChip(
        icon: Icons.payment_rounded,
        label: 'Pembayaran',
        value: paymentLabel,
      ),
      if (hasCashier)
        _InfoChip(
          icon: Icons.badge_outlined,
          label: 'Kasir',
          value: record.cashierName,
        ),
      _InfoChip(
        icon: Icons.check_circle_outline_rounded,
        label: 'Status',
        value: 'LUNAS',
        valueColor: Colors.green.shade700,
      ),
    ];

    if (isMobile) {
      return Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: item,
        )).toList(),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => IntrinsicWidth(child: item)).toList(),
    );
  }

  Widget _buildItemsTable(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAFTAR ITEM',
          style: manrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: DC.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: DC.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text('Item', style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant)),
              ),
              if (!isMobile)
                Expanded(
                  flex: 2,
                  child: Text('Harga', textAlign: TextAlign.right, style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant)),
                ),
              Expanded(
                flex: 1,
                child: Text('Qty', textAlign: TextAlign.center, style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant)),
              ),
              Expanded(
                flex: 2,
                child: Text('Jumlah', textAlign: TextAlign.right, style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant)),
              ),
            ],
          ),
        ),

        // Table Body
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.2)),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          child: Column(
            children: record.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == record.items.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: index.isEven ? DC.surfaceContainerLowest : DC.surfaceContainerLow.withValues(alpha: 0.3),
                  borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(11)) : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: manrope(fontSize: 14, fontWeight: FontWeight.w700, color: DC.onSurface),
                          ),
                          if (isMobile)
                            Text(
                              formatRupiah(item.price),
                              style: manrope(fontSize: 12, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    if (!isMobile)
                      Expanded(
                        flex: 2,
                        child: Text(
                          formatRupiah(item.price),
                          textAlign: TextAlign.right,
                          style: manrope(fontSize: 14, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant),
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: DC.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: manrope(fontSize: 13, fontWeight: FontWeight.w700, color: DC.onSurface),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        formatRupiah(item.quantity * item.price),
                        textAlign: TextAlign.right,
                        style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: DC.onSurface),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsSection(bool isMobile, storeProfile) {
    final storeName = storeProfile.storeName.isNotEmpty ? storeProfile.storeName : 'Toko Saya';
    final taxLabel = 'Pajak (${storeProfile.taxRate}%)';

    if (isMobile) {
      return _buildTotalsColumn(taxLabel);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes section
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DC.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DC.primary.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: DC.primary.withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Text('Catatan', style: manrope(fontSize: 12, fontWeight: FontWeight.w700, color: DC.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Terima kasih telah berbelanja di $storeName. Barang yang sudah dibeli tidak dapat ditukar/dikembalikan.',
                  style: manrope(fontSize: 12, fontWeight: FontWeight.w500, color: DC.onSurfaceVariant, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Totals
        Expanded(child: _buildTotalsColumn(taxLabel)),
      ],
    );
  }

  Widget _buildTotalsColumn(String taxLabel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          _TotalRow(label: 'Subtotal', value: formatRupiah(record.total - record.taxAmount)),
          const SizedBox(height: 10),
          _TotalRow(label: taxLabel, value: formatRupiah(record.taxAmount)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [DC.primary, DC.primary.withValues(alpha: 0.85)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: DC.onPrimary)),
                Text(formatRupiah(record.total), style: manrope(fontSize: 18, fontWeight: FontWeight.w900, color: DC.onPrimary)),
              ],
            ),
          ),
          if (record.paymentMethod == PaymentMethod.cash) ...[
            const SizedBox(height: 14),
            _TotalRow(label: 'Uang Tunai', value: formatRupiah(record.paidAmount ?? record.total)),
            const SizedBox(height: 8),
            _TotalRow(
              label: 'Kembalian',
              value: formatRupiah((record.paidAmount ?? record.total) - record.total),
              valueColor: DC.tertiary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DC.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, size: 18, color: Colors.green.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Transaksi berhasil diproses pada ${formatDateFull(record.createdAt)}',
              style: manrope(fontSize: 12, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ──

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoChip({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DC.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DC.onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: manrope(fontSize: 10, fontWeight: FontWeight.w700, color: DC.onSurfaceVariant, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value, style: manrope(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor ?? DC.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _TotalRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: manrope(fontSize: 14, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant)),
        Text(value, style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: valueColor ?? DC.onSurface)),
      ],
    );
  }
}

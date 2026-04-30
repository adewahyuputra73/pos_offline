import 'package:flutter/material.dart';
import 'package:border_po/models/transaction.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

class ReceiptDialog extends StatelessWidget {
  final TransactionRecord record;

  const ReceiptDialog({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: DC.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: DC.onSurface.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: DC.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVOICE',
                        style: manrope(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: DC.onSurface,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '#${record.id.toUpperCase()}',
                        style: manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DC.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'BARISTA POS',
                        style: manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: DC.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jalan Kenangan No. 123\nKota Kopi, Indonesia',
                        textAlign: TextAlign.right,
                        style: manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: DC.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Content ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InvoiceInfoItem(
                          label: 'Tanggal Transaksi',
                          value: formatDateFull(record.createdAt),
                        ),
                        _InvoiceInfoItem(
                          label: 'Metode Pembayaran',
                          value: paymentMethodToString(record.paymentMethod).toUpperCase(),
                        ),
                        _InvoiceInfoItem(
                          label: 'Status',
                          value: 'LUNAS',
                          valueColor: Colors.green.shade700,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: DC.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text('Deskripsi Item', style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('Qty', textAlign: TextAlign.center, style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Harga', textAlign: TextAlign.right, style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Jumlah', textAlign: TextAlign.right, style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Items List
                    ...record.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.productName,
                                style: manrope(fontSize: 14, fontWeight: FontWeight.w700, color: DC.onSurface),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: manrope(fontSize: 14, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                formatRupiah(item.price),
                                textAlign: TextAlign.right,
                                style: manrope(fontSize: 14, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant),
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
                    }),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Totals
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: DC.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Catatan Tambahan:', style: manrope(fontSize: 12, fontWeight: FontWeight.w700, color: DC.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                Text('Terima kasih telah berbelanja di Barista POS. Barang yang sudah dibeli tidak dapat ditukar/dikembalikan.', style: manrope(fontSize: 12, fontWeight: FontWeight.w500, color: DC.onSurfaceVariant, height: 1.5)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            children: [
                              _SummaryRow(label: 'Subtotal', value: formatRupiah(record.total - record.taxAmount)),
                              const SizedBox(height: 12),
                              _SummaryRow(label: 'Pajak (11%)', value: formatRupiah(record.taxAmount)),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: DC.primary,
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
                              const SizedBox(height: 16),
                              if (record.paymentMethod == PaymentMethod.cash) ...[
                                _SummaryRow(label: 'Uang Tunai', value: formatRupiah(record.paidAmount ?? record.total)),
                                const SizedBox(height: 8),
                                _SummaryRow(label: 'Kembalian', value: formatRupiah((record.paidAmount ?? record.total) - record.total)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // ── Actions ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: DC.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      foregroundColor: DC.onSurfaceVariant,
                    ),
                    child: Text('Tutup', style: manrope(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
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
                    label: const Text('Cetak / Simpan PDF'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DC.primary,
                      foregroundColor: DC.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InvoiceInfoItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: manrope(fontSize: 11, fontWeight: FontWeight.w700, color: DC.onSurfaceVariant, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: valueColor ?? DC.onSurface)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: manrope(fontSize: 14, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant)),
        Text(value, style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: DC.onSurface)),
      ],
    );
  }
}

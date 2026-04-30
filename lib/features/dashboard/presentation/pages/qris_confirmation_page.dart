import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

class QrisConfirmationPage extends StatelessWidget {
  final int totalToPay;

  const QrisConfirmationPage({
    super.key,
    required this.totalToPay,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: DC.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: DC.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DC.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pembayaran QRIS',
          style: manrope(fontWeight: FontWeight.w800, color: DC.onSurface),
        ),
      ),
      body: isMobile
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildOrderSummary(state),
                  _buildConfirmSection(context),
                ],
              ),
            )
          : Row(
              children: [
                Expanded(flex: 1, child: _buildOrderSummary(state)),
                Container(width: 1, color: DC.outlineVariant),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildConfirmSection(context),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderSummary(AppState state) {
    return Container(
      color: DC.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pesanan',
              style: manrope(fontSize: 18, fontWeight: FontWeight.w900, color: DC.onSurface, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: DC.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: DC.onSurface.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.cart.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = state.cart[index];
                  final product = state.products.firstWhere((p) => p.id == item.product.id);
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DC.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: manrope(fontSize: 12, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product.name,
                          style: manrope(fontSize: 14, fontWeight: FontWeight.w700, color: DC.onSurface),
                        ),
                      ),
                      Text(
                        formatRupiah(product.price * item.quantity),
                        style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: DC.onSurface),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DC.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: DC.onSurface.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'Subtotal', value: formatRupiah(state.cartTotal)),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Pajak (${state.storeProfile.taxRate}%)', value: formatRupiah(state.cartTaxAmount)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL',
                        style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: DC.onSurfaceVariant),
                      ),
                      Text(
                        formatRupiah(totalToPay),
                        style: manrope(fontSize: 20, fontWeight: FontWeight.w900, color: DC.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmSection(BuildContext context) {
    return Container(
      color: DC.surfaceContainerLowest,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),

          // QRIS Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DC.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 64,
              color: DC.primary.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Konfirmasi Pembayaran QRIS',
            textAlign: TextAlign.center,
            style: manrope(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: DC.onSurface,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Pastikan pelanggan telah menunjukkan bukti pembayaran QRIS yang valid sebelum mengonfirmasi.',
            textAlign: TextAlign.center,
            style: manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DC.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // Total to pay display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DC.primary.withValues(alpha: 0.06),
                  DC.primary.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: DC.primary.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: DC.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total yang Harus Dibayar',
                    style: manrope(fontSize: 11, fontWeight: FontWeight.w700, color: DC.primary, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatRupiah(totalToPay),
                    style: manrope(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: DC.onSurface,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Checklist reminder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFF57F17)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Periksa bahwa nominal pada bukti QRIS sesuai dengan total pembayaran.',
                    style: manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF57F17),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
              label: Text(
                'Konfirmasi Pembayaran',
                style: manrope(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: DC.primary,
                foregroundColor: DC.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: DC.onSurfaceVariant,
                side: BorderSide(color: DC.outlineVariant.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Batalkan',
                style: manrope(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
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
        Text(label, style: manrope(fontSize: 13, color: DC.onSurfaceVariant)),
        Text(value, style: manrope(fontSize: 13, fontWeight: FontWeight.w800, color: DC.onSurface)),
      ],
    );
  }
}

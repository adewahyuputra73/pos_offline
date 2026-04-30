import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

class CashPaymentPage extends StatefulWidget {
  final int totalToPay;

  const CashPaymentPage({
    super.key,
    required this.totalToPay,
  });

  @override
  State<CashPaymentPage> createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  int get _inputAmount {
    if (_amountController.text.isEmpty) return 0;
    return int.tryParse(_amountController.text) ?? 0;
  }

  void _onQuickAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    final change = _inputAmount - widget.totalToPay;
    final isEnough = _inputAmount >= widget.totalToPay;

    return Scaffold(
      backgroundColor: DC.surfaceContainerLowest,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: DC.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DC.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pembayaran Tunai',
          style: manrope(fontWeight: FontWeight.w800, color: DC.onSurface),
        ),
      ),
      body: isMobile
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildOrderSummary(state),
                  _buildInputSection(change, isEnough),
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
                    child: _buildInputSection(change, isEnough),
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
                        formatRupiah(widget.totalToPay),
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

  Widget _buildInputSection(int change, bool isEnough) {
    return Container(
      color: DC.surfaceContainerLowest,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Amount Input Field
          GestureDetector(
            onTap: () => _amountFocusNode.requestFocus(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isEnough
                      ? [DC.tertiary.withValues(alpha: 0.06), DC.tertiary.withValues(alpha: 0.02)]
                      : [DC.surfaceContainerHigh.withValues(alpha: 0.4), DC.surfaceContainerHigh.withValues(alpha: 0.2)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isEnough ? DC.tertiary.withValues(alpha: 0.4) : DC.outlineVariant.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: DC.onSurfaceVariant.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Uang Diterima',
                      style: manrope(fontSize: 11, fontWeight: FontWeight.w700, color: DC.onSurfaceVariant, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Hidden TextField for keyboard input
                  SizedBox(
                    height: 0,
                    child: Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                      ),
                    ),
                  ),
                  // Display value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _amountController.text.isEmpty ? 'Rp 0' : formatRupiah(_inputAmount),
                      style: manrope(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: _amountController.text.isEmpty
                            ? DC.onSurfaceVariant.withValues(alpha: 0.25)
                            : DC.onSurface,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk untuk memasukkan jumlah',
                    style: manrope(fontSize: 11, fontWeight: FontWeight.w600, color: DC.onSurfaceVariant.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Change Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: change < 0 ? DC.error.withValues(alpha: 0.05) : DC.tertiary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kembalian:',
                  style: manrope(fontSize: 14, fontWeight: FontWeight.w700, color: DC.onSurface),
                ),
                Text(
                  change < 0 ? 'Kurang ${formatRupiah(change.abs())}' : formatRupiah(change),
                  style: manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: change < 0 ? DC.error : DC.tertiary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick Amounts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                widget.totalToPay, // Uang Pas
                50000,
                100000,
                150000,
                200000,
              ].map((amt) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: Text(amt == widget.totalToPay ? 'Uang Pas' : formatRupiah(amt)),
                  labelStyle: manrope(fontWeight: FontWeight.w800, color: DC.onSurface, fontSize: 12),
                  backgroundColor: DC.surfaceContainerLowest,
                  side: BorderSide(color: DC.outlineVariant.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  onPressed: () => _onQuickAmount(amt),
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: isEnough ? () => Navigator.of(context).pop(_inputAmount) : null,
              style: FilledButton.styleFrom(
                backgroundColor: DC.primary,
                disabledBackgroundColor: DC.surfaceContainerHigh,
                disabledForegroundColor: DC.onSurfaceVariant.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Konfirmasi & Bayar',
                style: manrope(fontSize: 16, fontWeight: FontWeight.w900),
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

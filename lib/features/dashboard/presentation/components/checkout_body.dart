import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/product.dart';
import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';
import '../pages/cash_payment_page.dart';
import 'mobile_cart_floating_bar.dart';
import 'cart_panel.dart';
import '../pages/invoice_page.dart';
import '../pages/qris_confirmation_page.dart';

class CheckoutBody extends StatefulWidget {
  final Widget? leading;

  const CheckoutBody({super.key, this.leading});

  @override
  State<CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<CheckoutBody> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final state = context.watch<AppState>();
        final isWide = constraints.maxWidth >= 800;

        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Pane: Catalog
                Expanded(
                  flex: 5,
                  child: _buildCatalog(context, state, constraints.maxWidth),
                ),
                
                // Right Pane: Cart & Payment
                if (isWide)
                  Container(
                    width: 384,
                    decoration: BoxDecoration(
                      color: DC.surfaceContainerLowest,
                      border: Border(
                        left: BorderSide(
                          color: DC.outlineVariant.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DC.onSurface.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(-5, 0),
                        ),
                      ],
                    ),
                    child: _CheckoutSidebar(),
                  ),
              ],
            ),
            if (!isWide && state.cart.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MobileCartFloatingBar(
                  totalQty: state.cartItemCount,
                  grandTotal: state.cartGrandTotal,
                  onTap: () => _showCartBottomSheet(context, state),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showCartBottomSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: DC.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DC.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: CartPanel(
                  lines: state.cart,
                  onIncrement: (id) => state.incrementCartLine(id),
                  onDecrement: (id) => state.decrementCartLine(id),
                  onClear: () {
                    state.clearCart();
                    Navigator.pop(context);
                  },
                  onCheckout: () {
                    Navigator.pop(context);
                    // Show payment picker or just sidebar-like checkout
                    _showPaymentBottomSheet(context, state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentBottomSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: DC.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _CheckoutSidebar(),
        ),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context, AppState state, double maxWidth) {
    final compact = maxWidth < 600;
    final hasShift = state.hasActiveShift;
    final cashierName = state.activeShift?.cashierName ?? '';
    List<Product> products = state.productsByCategory(_selectedCategoryId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          color: DC.background,
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 24,
            compact ? 16 : 24,
            compact ? 16 : 24,
            0,
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PILIH PRODUK',
                      style: manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: DC.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasShift ? cashierName : 'Kasir',
                      style: manrope(
                        fontSize: compact ? 24 : 32,
                        fontWeight: FontWeight.w800,
                        color: DC.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Shift status chip
              if (hasShift)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SHIFT AKTIF',
                        style: manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF16A34A),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: DC.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 12, color: DC.error),
                      const SizedBox(width: 6),
                      Text(
                        'SHIFT BELUM BUKA',
                        style: manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: DC.error,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // No-shift warning banner
        if (!hasShift)
          Container(
            margin: EdgeInsets.fromLTRB(compact ? 16 : 24, 16, compact ? 16 : 24, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DC.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DC.error.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: DC.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Buka shift terlebih dahulu untuk memulai transaksi.',
                    style: manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DC.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Categories
        Container(
          color: DC.background,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 24,
            vertical: 16,
          ),
          height: 72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryTab(
                label: 'Semua',
                isActive: _selectedCategoryId == null,
                onTap: () => setState(() => _selectedCategoryId = null),
              ),
              ...state.categories.map((c) => _buildCategoryTab(
                    label: c.name,
                    isActive: _selectedCategoryId == c.id,
                    onTap: () => setState(() => _selectedCategoryId = c.id),
                  )),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: Container(
            color: DC.background,
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 24,
                0,
                compact ? 16 : 24,
                compact ? 16 : 24,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: maxWidth > 1000 ? 4 : (maxWidth > 600 ? 3 : 2),
                mainAxisSpacing: compact ? 8 : 16,
                crossAxisSpacing: compact ? 8 : 16,
                childAspectRatio: 0.65,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(context, products[index], state);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? DC.primary : DC.surfaceContainer,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              label,
              style: manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? DC.onPrimary : DC.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, Product product, AppState state) {
    final cat = state.categoryById(product.categoryId);
    final hasShift = state.hasActiveShift;
    return GestureDetector(
      onTap: () {
        if (!hasShift) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Buka shift kasir terlebih dahulu untuk bertransaksi.'),
                  ),
                ],
              ),
              backgroundColor: DC.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        context.read<AppState>().addToCart(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: DC.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: DC.primary.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: DC.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: product.imageBase64 != null &&
                          product.imageBase64!.isNotEmpty
                      ? Image.memory(
                          base64Decode(product.imageBase64!),
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: DC.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: DC.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (cat != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        cat.name.toUpperCase(),
                        style: manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: DC.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatRupiah(product.price),
                          style: manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: DC.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: DC.primaryFixedDim.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            size: 16,
                            color: DC.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutSidebar extends StatefulWidget {
  @override
  State<_CheckoutSidebar> createState() => _CheckoutSidebarState();
}

class _CheckoutSidebarState extends State<_CheckoutSidebar> {
  String _paymentMethod = 'cash'; // 'cash' or 'qris'

  // ── No-shift locked panel ──────────────────────────────────────────────────
  Widget _buildNoShiftPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DC.error.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_clock_rounded, size: 48, color: DC.error.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 20),
        Text(
          'Shift Belum Dibuka',
          style: manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: DC.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Buka shift kasir terlebih dahulu sebelum memproses transaksi.',
            textAlign: TextAlign.center,
            style: manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DC.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: DC.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DC.error.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: DC.error.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(
                'Buka menu SHIFT di sidebar',
                style: manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DC.error.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onPay(AppState state) async {
    if (state.cart.isEmpty) return;
    
    if (_paymentMethod == 'cash') {
      final paidAmount = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => CashPaymentPage(totalToPay: state.cartGrandTotal),
        ),
      );

      if (paidAmount != null && mounted) {
        _processCheckout(state, () => state.checkoutCash(paidAmount: paidAmount));
      }
    } else if (_paymentMethod == 'qris') {
      final confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => QrisConfirmationPage(totalToPay: state.cartGrandTotal),
        ),
      );

      if (confirmed == true && mounted) {
        _processCheckout(state, () => state.checkoutQris(imageBase64: ''));
      }
    }
  }

  Future<void> _processCheckout(AppState state, Future<void> Function() checkoutFn) async {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: DC.surfaceContainerLowest,
      builder: (ctx) => Scaffold(
        backgroundColor: DC.surfaceContainerLowest,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: DC.primary),
              const SizedBox(height: 24),
              Text(
                'Memproses pembayaran...',
                style: manrope(fontSize: 16, fontWeight: FontWeight.w700, color: DC.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Simulate slight network/processing delay for UX
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Keep track of the transaction ID before clearing cart to show receipt
      final nextId = 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'; // Just predicting ID if needed, or better, state should return it.
      // Wait, checkout method creates the transaction. Let's get the latest transaction after.

      await checkoutFn();

      if (!mounted) return;
      
      // Close Loading
      Navigator.of(context).pop();

      // Show Receipt — transactions getter sorts newest first, so .first is the latest
      final latestTx = state.transactions.first;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoicePage(record: latestTx),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      // Close Loading
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // When shift is not active, show a locked panel
    if (!state.hasActiveShift) {
      return _buildNoShiftPanel();
    }

    return Column(
      children: [
        // Sub-header Current Order (fixed at top)
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: DC.outlineVariant.withValues(alpha: 0.2))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: DC.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.cartItemCount} Items',
                      style: manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: DC.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.cart.isNotEmpty)
                IconButton(
                  onPressed: () => state.clearCart(),
                  icon: const Icon(Icons.delete_sweep, color: DC.onSurfaceVariant),
                  tooltip: 'Hapus Semua',
                ),
            ],
          ),
        ),

        // Everything else scrolls
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(bottom: bottomPadding),
            children: [
              // Cart items
              if (state.cart.isEmpty)
                SizedBox(
                  height: 200,
                  child: _buildEmptyCart(),
                )
              else
                ...state.cart.map((line) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _buildCartItem(context, line),
                )),

              // Stock warning
              if (state.cart.isNotEmpty && state.insufficientStockWarnings.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stok Bahan Tidak Cukup',
                                style: manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE65100),
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...state.insufficientStockWarnings.map((w) => Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '• $w',
                                  style: manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFBF360C),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Payment Panel
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: DC.surfaceContainerLowest,
                  boxShadow: [
                    BoxShadow(
                      color: DC.onSurface.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'METODE PEMBAYARAN',
                      style: manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: DC.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentMethodButton(
                            id: 'cash',
                            icon: Icons.payments_outlined,
                            label: 'Tunai',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPaymentMethodButton(
                            id: 'qris',
                            icon: Icons.qr_code_2_rounded,
                            label: 'QRIS',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (state.storeProfile.taxRate > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DC.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            formatRupiah(state.cartTotal),
                            style: manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DC.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pajak (${state.storeProfile.taxRate}%)',
                            style: manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DC.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            formatRupiah(state.cartTaxAmount),
                            style: manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DC.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Total Bayar',
                            style: manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: DC.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            formatRupiah(state.cartGrandTotal),
                            style: manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: DC.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: state.cart.isEmpty ? null : () => _onPay(state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DC.primary,
                        foregroundColor: DC.onPrimary,
                        disabledBackgroundColor: DC.surfaceContainerHigh,
                        disabledForegroundColor: DC.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _paymentMethod == 'cash' ? 'Kumpulkan Pembayaran' : 'Konfirmasi QRIS',
                        style: manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton({
    required String id,
    required IconData icon,
    required String label,
  }) {
    final isActive = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          color: isActive ? DC.primary : DC.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? DC.onPrimary : DC.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isActive ? DC.onPrimary : DC.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 48,
            color: DC.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DC.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          Text(
            'Klik produk untuk menambahkan',
            style: manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DC.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartLine line) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DC.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DC.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: line.product.imageBase64 != null &&
                    line.product.imageBase64!.isNotEmpty
                ? Image.memory(
                    base64Decode(line.product.imageBase64!),
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    color: DC.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  style: manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: DC.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity controls inside info block
                    Container(
                      decoration: BoxDecoration(
                        color: DC.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () => context
                                .read<AppState>()
                                .decrementCartLine(line.product.id),
                            color: DC.primary,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            padding: EdgeInsets.zero,
                          ),
                          Text(
                            '${line.quantity}',
                            style: manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: DC.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => context
                                .read<AppState>()
                                .incrementCartLine(line.product.id),
                            color: DC.primary,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatRupiah(line.product.price),
                      style: manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DC.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

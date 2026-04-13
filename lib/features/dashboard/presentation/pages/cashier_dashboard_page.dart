import 'package:flutter/material.dart';

import '../components/cart_panel.dart';
import '../components/category_tabs.dart';
import '../components/dashboard_top_bar.dart';
import '../components/mobile_cart_floating_bar.dart';
import '../components/product_card.dart';
import '../models/mock_data.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CashierDashboardPage — Presentation-only (mock data, local cart state).
///
/// ARCHITECTURE NOTE:
///   This page intentionally uses a local [StatefulWidget] to hold transient
///   cart state. Once we add the Domain + Data layers, this will become a
///   [ConsumerWidget] reading from a @riverpod CashierController, and the
///   StatefulWidget will be removed. No business logic lives here — only
///   UI wiring and layout decisions.
///
/// RESPONSIVE STRATEGY (via LayoutBuilder):
///   ≥ 900 dp  → Wide: product grid (left, flex 7) + persistent cart sidebar
///               (right, fixed 380 dp). Both always visible.
///   < 900 dp  → Compact: full-width grid + floating cart bar at bottom.
///               Tapping the bar opens a DraggableScrollableSheet.
/// ─────────────────────────────────────────────────────────────────────────────
class CashierDashboardPage extends StatefulWidget {
  const CashierDashboardPage({super.key});

  @override
  State<CashierDashboardPage> createState() => _CashierDashboardPageState();
}

class _CashierDashboardPageState extends State<CashierDashboardPage> {
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final Map<String, MockCartLine> _cart = {};

  // ── Derived values ──────────────────────────────────────────────────────────

  List<MockProduct> get _filteredProducts {
    return mockProducts.where((p) {
      final byCat =
          _selectedCategoryId == 'all' || p.categoryId == _selectedCategoryId;
      final byQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return byCat && byQuery;
    }).toList();
  }

  List<MockCartLine> get _cartLines => _cart.values.toList();
  int get _totalQty => _cart.values.fold(0, (s, l) => s + l.quantity);
  double get _cartSubtotal => _cart.values.fold(0, (s, l) => s + l.subtotal);
  double get _cartTotal => _cartSubtotal * 1.10;

  // ── Cart mutations ──────────────────────────────────────────────────────────

  void _addToCart(MockProduct p) => setState(() {
        final existing = _cart[p.id];
        if (existing == null) {
          _cart[p.id] = MockCartLine(product: p);
        } else {
          existing.quantity += 1;
        }
      });

  void _increment(String id) => setState(() {
        _cart[id]?.quantity += 1;
      });

  void _decrement(String id) => setState(() {
        final line = _cart[id];
        if (line == null) return;
        if (line.quantity <= 1) {
          _cart.remove(id);
        } else {
          line.quantity -= 1;
        }
      });

  void _clear() => setState(() => _cart.clear());

  // ── UI actions ──────────────────────────────────────────────────────────────

  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, __) {
            // StatefulBuilder so mutations propagate inside the sheet.
            return StatefulBuilder(
              builder: (ctx, setSheet) {
                void withSheetRefresh(VoidCallback fn) {
                  fn();
                  setSheet(() {});
                }

                return CartPanel(
                  lines: _cartLines,
                  onIncrement: (id) => withSheetRefresh(() => _increment(id)),
                  onDecrement: (id) => withSheetRefresh(() => _decrement(id)),
                  onClear: () => withSheetRefresh(_clear),
                  onCheckout: () {
                    Navigator.pop(sheetCtx);
                    _handleCheckout();
                  },
                  showHandle: true,
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleCheckout() {
    if (_cart.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        content: Text(
          'Checkout ${formatRupiah(_cartTotal)} — (mock, belum terhubung ke DB)',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 900;
            return isWide ? _buildWideLayout() : _buildCompactLayout();
          },
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // WIDE layout (tablet / landscape ≥ 900 dp)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildWideLayout() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left pane — top bar + categories + product grid
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardTopBar(
                  cashierName: 'Rani',
                  isCompact: false,
                  onSearchChanged: (v) =>
                      setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 20),
                CategoryTabs(
                  categories: mockCategories,
                  selectedCategoryId: _selectedCategoryId,
                  onSelected: (id) =>
                      setState(() => _selectedCategoryId = id),
                ),
                const SizedBox(height: 16),
                Expanded(child: _ProductGrid(
                  products: _filteredProducts,
                  cart: _cart,
                  onAddToCart: _addToCart,
                )),
              ],
            ),
          ),
        ),

        // Right pane — persistent cart sidebar
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 24, 20),
          child: SizedBox(
            width: 380,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CartPanel(
                  lines: _cartLines,
                  onIncrement: _increment,
                  onDecrement: _decrement,
                  onClear: _clear,
                  onCheckout: _handleCheckout,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // COMPACT layout (phone / portrait < 900 dp)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildCompactLayout() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: DashboardTopBar(
                cashierName: 'Rani',
                isCompact: true,
                onSearchChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: CategoryTabs(
                categories: mockCategories,
                selectedCategoryId: _selectedCategoryId,
                onSelected: (id) =>
                    setState(() => _selectedCategoryId = id),
              ),
            ),
            Expanded(
              child: Padding(
                // Reserve space at the bottom for the floating bar
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                child: _ProductGrid(
                  products: _filteredProducts,
                  cart: _cart,
                  onAddToCart: _addToCart,
                ),
              ),
            ),
          ],
        ),

        // Floating cart bar — animates in/out automatically
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MobileCartFloatingBar(
            totalQty: _totalQty,
            total: _cartTotal,
            onTap: _openCartSheet,
          ),
        ),
      ],
    );
  }
}

// ── Extracted stateless sub-widget ───────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final List<MockProduct> products;
  final Map<String, MockCartLine> cart;
  final void Function(MockProduct) onAddToCart;

  const _ProductGrid({
    required this.products,
    required this.cart,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const _EmptyProducts();

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        // Flutter auto-decides column count — no LayoutBuilder needed here.
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final p = products[i];
        return ProductCard(
          product: p,
          quantityInCart: cart[p.id]?.quantity ?? 0,
          onTap: () => onAddToCart(p),
        );
      },
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 44,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada produk',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba kata kunci atau kategori yang berbeda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

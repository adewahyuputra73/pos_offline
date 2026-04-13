import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/product.dart';
import 'package:border_po/state/app_state.dart';
import '../theme/dashboard_colors.dart';
import 'product_grid_card.dart';
import 'product_editor_sheet.dart';

/// Product Management body — replaces the dashboard body when
/// the "Products" nav item is selected.
///
/// Layout mirrors the Stitch HTML:
/// - Header ("Inventory Management" / "Produk Kami")
/// - Search bar + filter
/// - Category tabs (horizontal scroll)
/// - Responsive product grid (1-col mobile, 2-col tablet, 3-col wide)
/// - "Add Product" skeleton card at the end
class ProductManagementBody extends StatefulWidget {
  const ProductManagementBody({super.key});

  @override
  State<ProductManagementBody> createState() => _ProductManagementBodyState();
}

class _ProductManagementBodyState extends State<ProductManagementBody> {
  String _query = '';
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filteredProducts = state.products.where((p) {
      final matchQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase());
      final matchCat =
          _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
      return matchQuery && matchCat;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 400;

        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              _buildHeader(compact),
              SizedBox(height: compact ? 16 : 24),

              // ── Search + Filter row ───────────────────────────────────────
              _buildSearchBar(compact),
              SizedBox(height: compact ? 12 : 16),

              // ── Category tabs ─────────────────────────────────────────────
              _buildCategoryTabs(state),
              SizedBox(height: compact ? 16 : 24),

              // ── Product grid ──────────────────────────────────────────────
              _buildProductGrid(
                products: filteredProducts,
                state: state,
                screenWidth: width,
                compact: compact,
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header section ──────────────────────────────────────────────────────────

  Widget _buildHeader(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MANAJEMEN INVENTARIS',
          style: manrope(
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w600,
            color: DC.onSurfaceVariant,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Produk Kami',
          style: manrope(
            fontSize: compact ? 26 : 32,
            fontWeight: FontWeight.w800,
            color: DC.onSurface,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar(bool compact) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: DC.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: manrope(
                fontSize: 14,
                color: DC.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: manrope(
                  fontSize: 14,
                  color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: DC.onSurfaceVariant,
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: compact ? 12 : 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Category tabs ───────────────────────────────────────────────────────────

  Widget _buildCategoryTabs(AppState state) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryTab(
            label: 'Semua',
            isActive: _selectedCategoryId == null,
            onTap: () => setState(() => _selectedCategoryId = null),
          ),
          ...state.categories.map(
            (c) => _CategoryTab(
              label: c.name,
              isActive: _selectedCategoryId == c.id,
              onTap: () => setState(() => _selectedCategoryId = c.id),
            ),
          ),
        ],
      ),
    );
  }

  // ── Product grid ────────────────────────────────────────────────────────────

  Widget _buildProductGrid({
    required List<Product> products,
    required AppState state,
    required double screenWidth,
    required bool compact,
  }) {
    // Determine column count based on available width
    int crossAxisCount;
    if (screenWidth >= 800) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 3; // Force 3-col even on mobile as requested
    }


    // Build grid items
    final List<Widget> gridItems = [];

    for (int i = 0; i < products.length; i++) {
      final p = products[i];
      final cat = state.categoryById(p.categoryId);
      gridItems.add(
        ProductGridCard(
          product: p,
          category: cat,
          onEdit: () => ProductEditorSheet.show(context, existing: p),
          onDelete: () => _confirmDelete(context, p),
        ),
      );
    }

    // Add skeleton card
    gridItems.add(_buildAddCard(compact));

    // Empty state
    if (products.isEmpty && _query.isEmpty && _selectedCategoryId == null) {
      return _buildEmptyState();
    }

    if (products.isEmpty) {
      return _buildNoResults();
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: compact ? 8 : 16,
      crossAxisSpacing: compact ? 8 : 16,
      childAspectRatio: compact ? 0.60 : 0.65, // Adjusted to prevent 6px bottom overflow
      children: gridItems,
    );
  }

  Widget _buildAddCard(bool compact) {
    return GestureDetector(
      onTap: () => ProductEditorSheet.show(context),
      child: Container(
        decoration: BoxDecoration(
          color: DC.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DC.outlineVariant.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: DC.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 32,
                color: DC.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tambah Produk',
              style: manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DC.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Isi detail produk',
              style: manrope(
                fontSize: 11,
                color: DC.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: DC.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada produk',
              style: manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DC.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tambahkan produk pertama Anda.',
              style: manrope(
                fontSize: 13,
                color: DC.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => ProductEditorSheet.show(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: DC.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'TAMBAH PRODUK',
                  style: manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DC.onPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: DC.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada produk ditemukan',
              style: manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DC.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba ubah kata kunci atau filter.',
              style: manrope(
                fontSize: 12,
                color: DC.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete confirmation ─────────────────────────────────────────────────

  Future<void> _confirmDelete(BuildContext context, Product p) async {
    final state = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DC.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Hapus produk?',
          style: manrope(fontWeight: FontWeight.w700, color: DC.onSurface),
        ),
        content: Text(
          'Produk "${p.name}" akan dihapus permanen.',
          style: manrope(color: DC.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: manrope(
                fontWeight: FontWeight.w600,
                color: DC.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Hapus',
              style: manrope(
                fontWeight: FontWeight.w700,
                color: DC.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await state.deleteProduct(p.id);
    }
  }
}

// ── Category filter tab widget ──────────────────────────────────────────────

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? DC.primary : DC.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: manrope(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? DC.onPrimary : DC.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

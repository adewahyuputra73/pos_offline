import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/category.dart';
import 'package:border_po/state/app_state.dart';
import '../theme/dashboard_colors.dart';
import 'category_grid_card.dart';
import 'category_editor_sheet.dart';

class CategoryManagementBody extends StatelessWidget {
  const CategoryManagementBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = state.categories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        // Adjust layout density based on screen width
        final bool compact = screenWidth < 600;

        // Grid sizing
        int crossAxisCount;
        if (screenWidth >= 800) {
          crossAxisCount = 4;
        } else if (screenWidth >= 500) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2; // 2-col even on mobile
        }

        // Build grid items
        final List<Widget> gridItems = [];

        for (int i = 0; i < categories.length; i++) {
          final c = categories[i];
          final productCount = state.productsByCategory(c.id).length;
          gridItems.add(
            CategoryGridCard(
              category: c,
              productCount: productCount,
              onEdit: () => CategoryEditorSheet.show(context, existing: c),
              onDelete: () => _confirmDelete(context, c),
            ),
          );
        }

        // Add skeleton card
        gridItems.add(_buildAddCard(context, compact));

        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero / Header Section ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MANAGEMENT',
                      style: manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: DC.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Menu Categories',
                      style: manrope(
                        fontSize: compact ? 28 : 36,
                        fontWeight: FontWeight.w800,
                        color: DC.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Organize your shop's offerings into intuitive groups for faster checkout and inventory tracking.",
                      style: manrope(
                        fontSize: 14,
                        color: DC.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bento Grid ────────────────────────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: compact ? 2.0 : 2.2,
                ),
                itemCount: gridItems.length,
                itemBuilder: (ctx, idx) => gridItems[idx],
              ),
              
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddCard(BuildContext context, bool compact) {
    return GestureDetector(
      onTap: () => CategoryEditorSheet.show(context),
      child: Container(
        decoration: BoxDecoration(
          color: DC.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DC.outlineVariant.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DC.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: DC.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tambah Kategori',
                    style: manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: DC.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete confirmation ─────────────────────────────────────────────────

  Future<void> _confirmDelete(BuildContext context, ProductCategory c) async {
    final state = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DC.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Hapus kategori?',
          style: manrope(fontWeight: FontWeight.w700, color: DC.onSurface),
        ),
        content: Text(
          'Kategori "${c.name}" akan dihapus. Produk di dalamnya tidak akan terhapus namun status kategorinya akan dikosongkan.',
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
      await state.deleteCategory(c.id);
    }
  }
}

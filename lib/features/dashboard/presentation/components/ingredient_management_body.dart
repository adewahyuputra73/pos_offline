import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/ingredient.dart';
import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';
import 'ingredient_editor_sheet.dart';

class IngredientManagementBody extends StatelessWidget {
  const IngredientManagementBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ingredients = state.ingredients;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    Expanded(
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
                            'Bahan Baku (Inventory)',
                            style: manrope(
                              fontSize: compact ? 24 : 32,
                              fontWeight: FontWeight.w800,
                              color: DC.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Kelola stok bahan baku untuk otomatisasi modal dan inventaris.",
                            style: manrope(
                              fontSize: 14,
                              color: DC.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => IngredientEditorSheet.show(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Tambah Bahan'),
                      style: FilledButton.styleFrom(
                        backgroundColor: DC.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Empty state
              if (ingredients.isEmpty)
                _buildEmptyState(context)
              else
                _buildList(context, ingredients, compact),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.kitchen_outlined, size: 64, color: DC.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Belum Ada Bahan Baku', style: manrope(fontSize: 16, fontWeight: FontWeight.w700, color: DC.onSurface)),
            const SizedBox(height: 8),
            Text('Tambahkan bahan baku untuk membuat resep produk.', style: manrope(fontSize: 14, color: DC.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Ingredient> ingredients, bool compact) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final ing = ingredients[i];
        final bool outOfStock = ing.stock <= 0;
        final bool lowStock = ing.stock > 0 && ing.stock <= 50;

        // Stock status color
        final Color stockColor = outOfStock
            ? DC.error
            : lowStock
                ? const Color(0xFFE65100) // deep orange
                : DC.tertiary;
        final String stockLabel = outOfStock
            ? 'HABIS'
            : lowStock
                ? 'STOK RENDAH'
                : 'TERSEDIA';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DC.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: outOfStock
                  ? DC.error.withValues(alpha: 0.3)
                  : DC.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: outOfStock
                      ? DC.error.withValues(alpha: 0.1)
                      : DC.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  outOfStock ? Icons.warning_amber_rounded : Icons.eco_outlined,
                  color: outOfStock ? DC.error : DC.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ing.name,
                      style: manrope(fontSize: 16, fontWeight: FontWeight.w700, color: DC.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: stockColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            stockLabel,
                            style: manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: stockColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${ing.stock} ${ing.unit}',
                          style: manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: stockColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatRupiah(ing.costPerUnit)} / ${ing.unit}',
                    style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: DC.primary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: DC.onSurfaceVariant,
                        onPressed: () => IngredientEditorSheet.show(context, existing: ing),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: DC.error,
                        onPressed: () => _confirmDelete(context, ing),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Ingredient i) async {
    final state = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DC.surfaceContainerLowest,
        title: Text('Hapus Bahan?', style: manrope(fontWeight: FontWeight.w700)),
        content: Text('Bahan "${i.name}" akan dihapus dari sistem. Produk yang menggunakan bahan ini akan diupdate resipenya.', style: manrope(color: DC.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Hapus', style: TextStyle(color: DC.error))),
        ],
      ),
    );
    if (ok == true) {
      await state.deleteIngredient(i.id);
    }
  }
}

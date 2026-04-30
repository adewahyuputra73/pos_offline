import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:border_po/models/product.dart';
import 'package:border_po/models/category.dart';
import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';
import 'package:border_po/models/ingredient.dart';

/// Form dialog (bottom sheet) for adding and editing products.
/// Moved out of product_management_body.dart so it can be called
/// globally (e.g. from the dashboard FAB).
class ProductEditorSheet {
  static Future<void> show(BuildContext context, {Product? existing}) async {
    final state = context.read<AppState>();
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
      text:
          existing != null
              ? NumberFormat('#,###', 'id_ID').format(existing.price)
              : '',
    );
    final manualCostCtrl = TextEditingController(
      text:
          existing?.manualCost != null
              ? NumberFormat('#,###', 'id_ID').format(existing!.manualCost!)
              : '',
    );

    String? selectedCategoryId = existing?.categoryId;
    String? currentImageBase64 = existing?.imageBase64;

    // Copy the recipe so we can edit it locally
    List<RecipeItem> currentRecipe = List.from(existing?.recipe ?? []);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DC.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final viewInsets = MediaQuery.of(ctx).viewInsets;

            Future<void> pickImage() async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 400,
                maxHeight: 400,
                imageQuality: 70,
              );
              if (picked != null) {
                final bytes = await picked.readAsBytes();
                final b64 = base64Encode(bytes);
                setSheet(() {
                  currentImageBase64 = b64;
                });
              }
            }

            void addRecipeItem() async {
              if (state.ingredients.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Belum ada data bahan baku.')),
                );
                return;
              }

              String? selectedIngId = state.ingredients.first.id;
              final qtyCtrl = TextEditingController(text: '1');

              final result = await showDialog<RecipeItem>(
                context: ctx,
                builder:
                    (dCtx) => StatefulBuilder(
                      builder:
                          (dCtx, setDialog) => AlertDialog(
                            backgroundColor: DC.surfaceContainerLowest,
                            title: const Text('Tambah Bahan'),
                            scrollable: true,
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: selectedIngId,
                                    decoration: InputDecoration(
                                      labelText: 'Bahan Baku',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    items:
                                        state.ingredients
                                            .map(
                                              (ing) => DropdownMenuItem(
                                                value: ing.id,
                                                child: Text(
                                                  '${ing.name} (${ing.unit})',
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        (v) => setDialog(() => selectedIngId = v),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: qtyCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Jumlah Pakai',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dCtx).pop(),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  final qty = int.tryParse(qtyCtrl.text) ?? 1;
                                  if (selectedIngId != null) {
                                    Navigator.of(dCtx).pop(
                                      RecipeItem(
                                        ingredientId: selectedIngId!,
                                        quantity: qty,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Tambah'),
                              ),
                            ],
                          ),
                    ),
              );

              if (result != null) {
                setSheet(() {
                  currentRecipe.add(result);
                });
              }
            }

            // Calculate auto cost
            int autoCost = 0;
            for (final item in currentRecipe) {
              final ing =
                  state.ingredients
                      .where((i) => i.id == item.ingredientId)
                      .firstOrNull;
              if (ing != null) autoCost += (ing.costPerUnit * item.quantity);
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: DC.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      isEdit ? 'Edit Produk' : 'Tambah Produk',
                      style: manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: DC.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: DC.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: DC.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              currentImageBase64 != null
                                  ? Image.memory(
                                    base64Decode(currentImageBase64!),
                                    fit: BoxFit.cover,
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: DC.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Foto',
                                        style: manrope(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: DC.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name field
                    _StyledField(
                      controller: nameCtrl,
                      label: 'Nama produk',
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),

                    // Price field
                    _StyledField(
                      controller: priceCtrl,
                      label: 'Harga Jual (Rp)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ThousandSeparatorFormatter(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category selector
                    if (state.categories.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DC.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Belum ada kategori. Produk akan dibuat tanpa kategori.',
                          style: manrope(
                            fontSize: 12,
                            color: DC.onSurfaceVariant,
                          ),
                        ),
                      )
                    else ...[
                      Text(
                        'Kategori',
                        style: manrope(
                          fontWeight: FontWeight.w700,
                          color: DC.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Horizontal scroll in case there are many categories
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip(
                              label: 'Tanpa kategori',
                              selected: selectedCategoryId == null,
                              onTap:
                                  () =>
                                      setSheet(() => selectedCategoryId = null),
                            ),
                            ...state.categories.map(
                              (c) => _buildCategoryChip(
                                label: c.name,
                                selected: selectedCategoryId == c.id,
                                onTap:
                                    () => setSheet(
                                      () => selectedCategoryId = c.id,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Recipe Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resep / Bahan Baku',
                          style: manrope(
                            fontWeight: FontWeight.w700,
                            color: DC.onSurface,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: addRecipeItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Bahan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (currentRecipe.isEmpty)
                      Text(
                        'Tidak ada resep. Gunakan modal manual jika diperlukan.',
                        style: manrope(
                          fontSize: 12,
                          color: DC.onSurfaceVariant,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentRecipe.length,
                        itemBuilder: (ctx, i) {
                          final item = currentRecipe[i];
                          final ing =
                              state.ingredients
                                  .where((ig) => ig.id == item.ingredientId)
                                  .firstOrNull;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(ing?.name ?? 'Unknown Ingredient'),
                            subtitle: Text(
                              '${item.quantity} ${ing?.unit ?? ''}  (@ Rp${ing?.costPerUnit ?? 0})',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: DC.error,
                              ),
                              onPressed:
                                  () =>
                                      setSheet(() => currentRecipe.removeAt(i)),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 16),
                    if (currentRecipe.isEmpty)
                      _StyledField(
                        controller: manualCostCtrl,
                        label: 'Modal Manual (Rp) - Opsional',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ThousandSeparatorFormatter(),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DC.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Total Modal Otomatis: Rp $autoCost',
                          style: manrope(
                            fontWeight: FontWeight.w700,
                            color: DC.onPrimaryContainer,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Submit button
                    GestureDetector(
                      onTap: () async {
                        final name = nameCtrl.text.trim();
                        final price = parseFormattedNumber(
                          priceCtrl.text.trim(),
                        );
                        final mCost =
                            currentRecipe.isEmpty
                                ? parseFormattedNumber(
                                  manualCostCtrl.text.trim(),
                                )
                                : null;

                        if (name.isEmpty || price <= 0) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Nama dan harga wajib diisi',
                                style: manrope(color: Colors.white),
                              ),
                              backgroundColor: DC.error,
                            ),
                          );
                          return;
                        }
                        if (isEdit) {
                          await state.updateProduct(
                            id: existing.id,
                            name: name,
                            price: price,
                            categoryId: selectedCategoryId,
                            imageBase64: currentImageBase64,
                            recipe: currentRecipe,
                            manualCost: mCost,
                          );
                        } else {
                          await state.addProduct(
                            name: name,
                            price: price,
                            categoryId: selectedCategoryId,
                            imageBase64: currentImageBase64,
                            recipe: currentRecipe,
                            manualCost: mCost,
                          );
                        }
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [DC.primary, DC.primaryDim],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                            style: manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DC.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildCategoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? DC.primary : DC.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: manrope(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? DC.onPrimary : DC.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

// ── Styled text field ───────────────────────────────────────────────────────

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _StyledField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DC.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: manrope(fontSize: 14, color: DC.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: manrope(
            fontSize: 14,
            color: DC.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

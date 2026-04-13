import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:border_po/models/product.dart';
import 'package:border_po/models/category.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

/// Individual product card matching the Stitch "Product Management" design.
///
/// Shows a square image area (icon placeholder), product name, price,
/// category label, and action chips. Tap to edit, long-press for delete.
class ProductGridCard extends StatefulWidget {
  final Product product;
  final ProductCategory? category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductGridCard({
    super.key,
    required this.product,
    this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? widget.onEdit,
      onLongPress: () => _showActions(context),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
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
            mainAxisSize: MainAxisSize.min,
            children: [
            // ── Image area ──────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: DC.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.product.imageBase64 != null &&
                        widget.product.imageBase64!.isNotEmpty
                    ? Image.memory(
                        base64Decode(widget.product.imageBase64!),
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          _categoryIcon(widget.category?.name),
                          size: 40,
                          color: DC.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Details ─────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Name + Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: DC.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatRupiah(widget.product.price),
                        style: manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: DC.primary,
                        ),
                      ),
                    ],
                  ),

                  // Category label
                  if (widget.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.category!.name.toUpperCase(),
                      style: manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: DC.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Action row
                  Row(
                    children: [
                      if (widget.onEdit != null)
                        _ActionChip(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          onTap: widget.onEdit!,
                        ),
                      if (widget.onDelete != null) ...[
                        const SizedBox(width: 6),
                        _ActionChip(
                          icon: Icons.delete_outline,
                          label: 'Hapus',
                          onTap: widget.onDelete!,
                          isDestructive: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DC.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: DC.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.product.name,
                style: manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: DC.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (widget.onEdit != null)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Produk'),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onEdit!();
                  },
                ),
              if (widget.onDelete != null)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: DC.error),
                  title: Text('Hapus Produk',
                      style: TextStyle(color: DC.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onDelete!();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.inventory_2_outlined;
    final lower = categoryName.toLowerCase();
    if (lower.contains('kopi') || lower.contains('coffee') || lower.contains('espresso')) {
      return Icons.coffee_outlined;
    }
    if (lower.contains('teh') || lower.contains('tea') || lower.contains('matcha')) {
      return Icons.emoji_food_beverage_outlined;
    }
    if (lower.contains('roti') || lower.contains('pastry') || lower.contains('kue')) {
      return Icons.bakery_dining_outlined;
    }
    if (lower.contains('minuman') || lower.contains('drink') || lower.contains('jus')) {
      return Icons.local_bar_outlined;
    }
    if (lower.contains('makanan') || lower.contains('food') || lower.contains('snack')) {
      return Icons.restaurant_outlined;
    }
    return Icons.inventory_2_outlined;
  }
}

/// Small action chip for edit/delete buttons inside product cards.
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDestructive
              ? DC.error.withValues(alpha: 0.08)
              : DC.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isDestructive ? DC.error : DC.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDestructive ? DC.error : DC.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

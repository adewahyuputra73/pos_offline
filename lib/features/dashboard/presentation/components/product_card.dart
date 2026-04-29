import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:border_po/models/product.dart';
import 'package:border_po/utils/formatters.dart';

/// Individual product tile shown inside the grid.
///
/// Purely presentational — takes a product, the current in-cart quantity,
/// and a tap callback.
class ProductCard extends StatelessWidget {
  final Product product;
  final int quantityInCart;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantityInCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bool inCart = quantityInCart > 0;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: inCart
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.outlineVariant.withValues(alpha: 0.5),
            width: inCart ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child: _ProductThumbnail(
                    product: product,
                    inCart: inCart,
                    quantityInCart: quantityInCart,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatRupiah(product.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scheme.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final Product product;
  final bool inCart;
  final int quantityInCart;

  const _ProductThumbnail({
    required this.product,
    required this.inCart,
    required this.quantityInCart,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: scheme.primary.withValues(alpha: 0.08),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: product.imageBase64 != null &&
                    product.imageBase64!.isNotEmpty
                ? Image.memory(
                    base64Decode(product.imageBase64!),
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 46,
                      color: scheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
          ),
        ),
        if (inCart)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '$quantityInCart',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

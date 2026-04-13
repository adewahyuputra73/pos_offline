import 'package:flutter/material.dart';

import '../models/mock_data.dart';
import 'cart_item_tile.dart';

/// Reusable cart panel — used as a persistent sidebar on wide screens
/// and inside a [DraggableScrollableSheet] on phones.
///
/// Contains: header, scrollable item list, and a sticky checkout footer.
class CartPanel extends StatelessWidget {
  final List<MockCartLine> lines;
  final void Function(String productId) onIncrement;
  final void Function(String productId) onDecrement;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  /// Shows a drag handle at the top — set true when used in a bottom sheet.
  final bool showHandle;

  const CartPanel({
    super.key,
    required this.lines,
    required this.onIncrement,
    required this.onDecrement,
    required this.onClear,
    required this.onCheckout,
    this.showHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final double subtotal = lines.fold(0, (s, l) => s + l.subtotal);
    final double tax = subtotal * 0.10;
    final double total = subtotal + tax;
    final int totalQty = lines.fold(0, (s, l) => s + l.quantity);

    return Column(
      children: [
        if (showHandle) _DragHandle(),
        _CartHeader(
          totalQty: totalQty,
          hasItems: lines.isNotEmpty,
          onClear: onClear,
        ),
        const _Divider(),
        Expanded(
          child: lines.isEmpty
              ? const _EmptyCartPlaceholder()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final l = lines[i];
                    return CartItemTile(
                      line: l,
                      onIncrement: () => onIncrement(l.product.id),
                      onDecrement: () => onDecrement(l.product.id),
                    );
                  },
                ),
        ),
        _CheckoutFooter(
          subtotal: subtotal,
          tax: tax,
          total: total,
          disabled: lines.isEmpty,
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}

// ── Sub-components ────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  final int totalQty;
  final bool hasItems;
  final VoidCallback onClear;

  const _CartHeader({
    required this.totalQty,
    required this.hasItems,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: scheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pesanan Aktif',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (totalQty > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$totalQty item',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ),
          if (hasItems) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: 'Hapus semua',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.delete_sweep_rounded,
                      color: scheme.error,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color:
          Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _EmptyCartPlaceholder extends StatelessWidget {
  const _EmptyCartPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: scheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Keranjang kosong',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih produk di sebelah kiri\nuntuk memulai pesanan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.55),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final bool disabled;
  final VoidCallback onCheckout;

  const _CheckoutFooter({
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.disabled,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: 'Subtotal', value: subtotal, theme: theme),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Pajak (10%)',
            value: tax,
            theme: theme,
            dimValue: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          Row(
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                formatRupiah(total),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: disabled ? null : onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: scheme.primary.withValues(alpha: 0.3),
                disabledForegroundColor: Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              icon: const Icon(Icons.lock_rounded, size: 20),
              label: const Text('Proses Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final ThemeData theme;
  final bool dimValue;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.theme,
    this.dimValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const Spacer(),
        Text(
          formatRupiah(value),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: dimValue
                ? scheme.onSurface.withValues(alpha: 0.65)
                : scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

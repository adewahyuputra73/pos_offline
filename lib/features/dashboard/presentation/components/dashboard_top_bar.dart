import 'package:flutter/material.dart';

/// Top bar for the cashier dashboard.
///
/// Supports a wide mode (branding + inline search + action icons in one row)
/// and a compact mode (branding row, search field stacked below) chosen by
/// the parent page based on [LayoutBuilder] constraints.
class DashboardTopBar extends StatelessWidget {
  final String cashierName;
  final String searchHint;
  final bool isCompact;
  final ValueChanged<String> onSearchChanged;

  const DashboardTopBar({
    super.key,
    required this.cashierName,
    required this.onSearchChanged,
    this.isCompact = false,
    this.searchHint = 'Cari produk, kode, atau SKU…',
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _BrandBlock(cashierName: cashierName),
              const Spacer(),
              _IconChip(icon: Icons.notifications_none_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _IconChip(icon: Icons.settings_outlined, onTap: () {}),
            ],
          ),
          const SizedBox(height: 14),
          _SearchField(hint: searchHint, onChanged: onSearchChanged),
        ],
      );
    }

    return Row(
      children: [
        _BrandBlock(cashierName: cashierName),
        const SizedBox(width: 20),
        Expanded(
          child: _SearchField(hint: searchHint, onChanged: onSearchChanged),
        ),
        const SizedBox(width: 16),
        _IconChip(icon: Icons.notifications_none_rounded, onTap: () {}),
        const SizedBox(width: 8),
        _IconChip(icon: Icons.settings_outlined, onTap: () {}),
      ],
    );
  }
}

class _BrandBlock extends StatelessWidget {
  final String cashierName;
  const _BrandBlock({required this.cashierName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.storefront_rounded, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Halo, $cashierName',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Kasir Border PO',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          hintText: hint,
          hintStyle: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.45),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconChip({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: scheme.onSurface),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'categories_screen.dart';
import 'products_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: false,
          floating: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text('Pengaturan'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _section('Manajemen'),
              _Tile(
                icon: Icons.inventory_2_outlined,
                label: 'Produk',
                subtitle: 'Tambah, ubah, hapus produk',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _Tile(
                icon: Icons.category_outlined,
                label: 'Kategori',
                subtitle: 'Atur kategori produk',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
              ),
              const SizedBox(height: 24),
              _section('Data'),
              _Tile(
                icon: Icons.delete_sweep_outlined,
                label: 'Hapus semua transaksi',
                subtitle: 'Riwayat transaksi akan dihapus permanen',
                danger: true,
                onTap: () => _confirmDeleteTransactions(context),
              ),
              const SizedBox(height: 10),
              _Tile(
                icon: Icons.layers_clear_outlined,
                label: 'Hapus semua data',
                subtitle:
                    'Produk, kategori, dan transaksi akan dihapus permanen',
                danger: true,
                onTap: () => _confirmClearAll(context),
              ),
              const SizedBox(height: 24),
              _section('Tentang'),
              _Tile(
                icon: Icons.coffee_outlined,
                label: 'Border PO',
                subtitle: 'POS sederhana — offline first',
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      );

  Future<void> _confirmDeleteTransactions(BuildContext context) async {
    final state = context.read<AppState>();
    final ok = await _showConfirmDialog(
      context,
      title: 'Hapus semua transaksi?',
      message:
          'Seluruh riwayat transaksi akan dihapus permanen. Tindakan ini '
          'tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
    );
    if (ok != true) return;
    await state.clearTransactions();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua transaksi telah dihapus.')),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final state = context.read<AppState>();
    final ok = await _showConfirmDialog(
      context,
      title: 'Hapus semua data?',
      message:
          'Produk, kategori, dan transaksi akan dihapus permanen. Tindakan '
          'ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus semua',
    );
    if (ok != true) return;
    await state.clearAllData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua data telah dihapus.')),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool danger;

  const _Tile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.primary;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: danger ? AppColors.danger : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

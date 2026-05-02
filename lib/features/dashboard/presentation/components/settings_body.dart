import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/store_profile.dart';
import 'package:border_po/state/app_state.dart';
import '../theme/dashboard_colors.dart';
import '../components/top_bar_widget.dart';
import 'product_management_body.dart';
import 'category_management_body.dart';

/// Settings page with tabbed sub-sections:
/// Products, Categories, Store Profile, Data Export.
class SettingsBody extends StatefulWidget {
  final Widget? leading;

  const SettingsBody({super.key, this.leading});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  int _activeTab = 0;

  static const _tabs = ['Produk', 'Kategori', 'Toko', 'Export'];
  static const _tabIcons = [
    Icons.inventory_2_outlined,
    Icons.category_outlined,
    Icons.storefront_outlined,
    Icons.file_download_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── TopBar with Tabs ──────────────────────────────────────────────
        TopBarWidget(
          leading: widget.leading,
          titleWidget: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final isActive = _activeTab == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? DC.primary
                            : DC.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _tabIcons[i],
                            size: 16,
                            color: isActive
                                ? DC.onPrimary
                                : DC.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _tabs[i],
                            style: manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? DC.onPrimary
                                  : DC.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // ── Tab Content ──────────────────────────────────────────────
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return const ProductManagementBody();
      case 1:
        return const CategoryManagementBody();
      case 2:
        return const _StoreAndExportTab();
      case 3:
        return const _ExportOnlyTab();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Store & General Settings Tab ────────────────────────────────────────────

class _StoreAndExportTab extends StatelessWidget {
  const _StoreAndExportTab();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16.0 : 24.0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StoreProfileCard(),
              SizedBox(height: 24),
              _DangerZoneCard(),
              SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}

// ── Export Only Tab ──────────────────────────────────────────────────────────

class _ExportOnlyTab extends StatelessWidget {
  const _ExportOnlyTab();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16.0 : 24.0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DataExportCard(),
              SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}

// ── Store Profile Card ──────────────────────────────────────────────────────

class _StoreProfileCard extends StatelessWidget {
  const _StoreProfileCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.storeProfile;
    final hasData = profile.storeName.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DC.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: DC.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Toko',
                      style: manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: DC.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasData
                          ? profile.storeName
                          : 'Belum diatur — data ini digunakan untuk struk.',
                      style: manrope(
                        fontSize: 12,
                        color: DC.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasData) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DC.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileRow(label: 'Nama Toko', value: profile.storeName),
                  const SizedBox(height: 8),
                  _ProfileRow(label: 'Alamat', value: profile.address),
                  const SizedBox(height: 8),
                  _ProfileRow(label: 'Telepon', value: profile.phone),
                  if (profile.tagline != null &&
                      profile.tagline!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ProfileRow(label: 'Tagline', value: profile.tagline!),
                  ],
                  const SizedBox(height: 8),
                  _ProfileRow(label: 'Pajak (%)', value: profile.taxRate.toStringAsFixed(1)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showProfileEditor(context, profile),
            child: Text(
              hasData ? 'UBAH DETAIL' : 'ATUR SEKARANG',
              style: manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: DC.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileEditor(BuildContext context, StoreProfile profile) {
    final state = context.read<AppState>();
    final nameCtrl = TextEditingController(text: profile.storeName);
    final addressCtrl = TextEditingController(text: profile.address);
    final phoneCtrl = TextEditingController(text: profile.phone);
    final taglineCtrl = TextEditingController(text: profile.tagline ?? '');
    final taxRateCtrl = TextEditingController(text: profile.taxRate.toString());

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DC.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                Text(
                  'Profil Toko',
                  style: manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DC.onSurface,
                  ),
                ),
                Text(
                  'Data ini akan tampil di header struk dan nota kasir.',
                  style: manrope(fontSize: 12, color: DC.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                _SettingsField(controller: nameCtrl, label: 'Nama Toko'),
                const SizedBox(height: 12),
                _SettingsField(controller: addressCtrl, label: 'Alamat'),
                const SizedBox(height: 12),
                _SettingsField(
                  controller: phoneCtrl,
                  label: 'Telepon',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _SettingsField(
                    controller: taglineCtrl, label: 'Tagline (opsional)'),
                const SizedBox(height: 12),
                _SettingsField(
                  controller: taxRateCtrl,
                  label: 'Pajak / PPN (%) (contoh: 11 atau 10.5)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () async {
                    final updated = StoreProfile(
                      storeName: nameCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      tagline: taglineCtrl.text.trim().isEmpty
                          ? null
                          : taglineCtrl.text.trim(),
                      taxRate: double.tryParse(taxRateCtrl.text.trim()) ?? 0.0,
                    );
                    await state.updateStoreProfile(updated);
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
                        'Simpan Profil',
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
  }
}

// ── Danger Zone Card (Wipe All Data) ────────────────────────────────────────

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DC.error.withValues(alpha: 0.1),
        border: Border.all(color: DC.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: DC.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Zona Berbahaya',
                style: manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DC.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Menghapus semua data (produk, bahan baku, transaksi, riwayat shift, profil). Aplikasi akan kembali ke kondisi awal seperti baru di-install. Tindakan ini tidak bisa dibatalkan.',
            style: manrope(
              fontSize: 13,
              color: DC.error,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: Text('Hapus Semua Data', style: manrope(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: DC.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _showConfirmDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DC.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: DC.error),
            const SizedBox(width: 8),
            Text('Hapus Semua Data?', style: manrope(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus SEMUA data aplikasi? Semua produk, bahan baku, transaksi, dan riwayat shift akan hilang permanen.',
          style: manrope(fontSize: 14, color: DC.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: manrope(color: DC.onSurfaceVariant, fontWeight: FontWeight.w700)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: DC.error),
            onPressed: () async {
              final state = context.read<AppState>();
              await state.clearAllData();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Semua data berhasil dihapus.', style: manrope(color: Colors.white)),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Ya, Hapus Semua', style: manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Data Export Card ─────────────────────────────────────────────────────────

class _DataExportCard extends StatelessWidget {
  const _DataExportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.file_download_outlined, color: DC.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Data Export',
                style: manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DC.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Generate comprehensive reports for your accounting. All exports are generated in professional format.',
            style: manrope(
              fontSize: 13,
              color: DC.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _ExportButton(
            label: 'Export Sales Data',
            icon: Icons.download_rounded,
            helperText: 'Excel (.xlsx) format including taxes and discounts.',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Export data penjualan belum tersedia.',
                    style: manrope(color: Colors.white),
                  ),
                  backgroundColor: DC.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExportButton(
            label: 'Export Transactions',
            icon: Icons.table_chart_outlined,
            helperText: 'Excel (.xlsx) format with unique transaction IDs.',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Export transaksi belum tersedia.',
                    style: manrope(color: Colors.white),
                  ),
                  backgroundColor: DC.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Export Button ────────────────────────────────────────────────────────────

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String helperText;
  final VoidCallback onTap;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.helperText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DC.primary, DC.primaryDim],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DC.onPrimary,
                  ),
                ),
                Icon(icon, color: DC.onPrimary, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            helperText,
            style: manrope(fontSize: 11, color: DC.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

// ── Profile row ─────────────────────────────────────────────────────────────

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: DC.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: manrope(fontSize: 13, color: DC.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Styled field for settings ───────────────────────────────────────────────

class _SettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const _SettingsField({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
        style: manrope(fontSize: 14, color: DC.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: manrope(
            fontSize: 14,
            color: DC.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

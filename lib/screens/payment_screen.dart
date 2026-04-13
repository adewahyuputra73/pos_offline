import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'transaction_detail_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.cash;

  // Cash state
  int _paid = 0;

  // QRIS state
  String? _qrisBase64;
  bool _capturing = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total = state.cartTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TotalCard(total: total, items: state.cartItemCount),
              const SizedBox(height: 20),
              const Text(
                'Metode pembayaran',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MethodTile(
                      label: 'Tunai',
                      icon: Icons.payments_outlined,
                      selected: _method == PaymentMethod.cash,
                      onTap: () => setState(() => _method = PaymentMethod.cash),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MethodTile(
                      label: 'QRIS',
                      icon: Icons.qr_code_2_outlined,
                      selected: _method == PaymentMethod.qris,
                      onTap: () => setState(() => _method = PaymentMethod.qris),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _method == PaymentMethod.cash
                      ? _CashPanel(
                          total: total,
                          paid: _paid,
                          onPaidChanged: (v) => setState(() => _paid = v),
                        )
                      : _QrisPanel(
                          imageBase64: _qrisBase64,
                          capturing: _capturing,
                          onCapture: _captureQris,
                          onClear: () => setState(() => _qrisBase64 = null),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _canConfirm(total) ? () => _confirm(state) : null,
                child: const Text('Konfirmasi pembayaran'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canConfirm(int total) {
    if (total <= 0) return false;
    if (_method == PaymentMethod.cash) {
      return _paid >= total;
    }
    return _qrisBase64 != null;
  }

  Future<void> _captureQris() async {
    setState(() => _capturing = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
        maxWidth: 1280,
      );
      if (picked == null) return;
      final bytes = await File(picked.path).readAsBytes();
      setState(() => _qrisBase64 = base64Encode(bytes));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _confirm(AppState state) async {
    final TransactionRecord tx;
    if (_method == PaymentMethod.cash) {
      tx = await state.checkoutCash(paidAmount: _paid);
    } else {
      tx = await state.checkoutQris(imageBase64: _qrisBase64!);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(
          transaction: tx,
          showSuccessBanner: true,
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int total;
  final int items;
  const _TotalCard({required this.total, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$items item',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatRupiah(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : AppColors.primary,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- CASH -----------------

class _CashPanel extends StatelessWidget {
  final int total;
  final int paid;
  final ValueChanged<int> onPaidChanged;

  const _CashPanel({
    required this.total,
    required this.paid,
    required this.onPaidChanged,
  });

  @override
  Widget build(BuildContext context) {
    final change = paid - total;
    final quickAmounts = _suggestQuickAmounts(total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uang diterima',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatRupiah(paid),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Text(
                    'Kembalian',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    change >= 0 ? formatRupiah(change) : '—',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: change >= 0
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cepat',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              label: const Text('Uang pas'),
              onPressed: () => onPaidChanged(total),
            ),
            ...quickAmounts.map(
              (a) => ActionChip(
                label: Text(formatRupiah(a)),
                onPressed: () => onPaidChanged(a),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _NumPad(
          onDigit: (d) {
            final next = int.tryParse('$paid$d') ?? paid;
            onPaidChanged(next);
          },
          onBackspace: () {
            final s = paid.toString();
            if (s.length <= 1) {
              onPaidChanged(0);
            } else {
              onPaidChanged(int.tryParse(s.substring(0, s.length - 1)) ?? 0);
            }
          },
          onClear: () => onPaidChanged(0),
        ),
      ],
    );
  }

  List<int> _suggestQuickAmounts(int total) {
    if (total <= 0) return const [];
    const denominations = [1000, 2000, 5000, 10000, 20000, 50000, 100000];
    // Round up to next "nice" denominations greater than total
    final result = <int>{};
    for (final d in denominations) {
      if (d > total) result.add(d);
    }
    // Also include the next round 50k/100k after total
    final next50k = ((total ~/ 50000) + 1) * 50000;
    final next100k = ((total ~/ 100000) + 1) * 100000;
    result.add(next50k);
    result.add(next100k);
    final list = result.toList()..sort();
    return list.take(5).toList();
  }
}

class _NumPad extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const _NumPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    Widget keyBtn(String label, VoidCallback onTap, {bool wide = false}) {
      return Expanded(
        flex: wide ? 1 : 1,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget iconKey(IconData icon, VoidCallback onTap) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [
          keyBtn('1', () => onDigit(1)),
          keyBtn('2', () => onDigit(2)),
          keyBtn('3', () => onDigit(3)),
        ]),
        Row(children: [
          keyBtn('4', () => onDigit(4)),
          keyBtn('5', () => onDigit(5)),
          keyBtn('6', () => onDigit(6)),
        ]),
        Row(children: [
          keyBtn('7', () => onDigit(7)),
          keyBtn('8', () => onDigit(8)),
          keyBtn('9', () => onDigit(9)),
        ]),
        Row(children: [
          iconKey(Icons.refresh, onClear),
          keyBtn('0', () => onDigit(0)),
          iconKey(Icons.backspace_outlined, onBackspace),
        ]),
      ],
    );
  }
}

// ----------------- QRIS -----------------

class _QrisPanel extends StatelessWidget {
  final String? imageBase64;
  final bool capturing;
  final VoidCallback onCapture;
  final VoidCallback onClear;

  const _QrisPanel({
    required this.imageBase64,
    required this.capturing,
    required this.onCapture,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bayar menggunakan QRIS eksternal. Setelah pembayaran, '
                  'ambil bukti dengan kamera.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageBase64 == null
                ? Center(
                    child: capturing
                        ? const CircularProgressIndicator(
                            color: AppColors.primary,
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.photo_camera_outlined,
                                color: AppColors.textSecondary,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada bukti pembayaran',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  )
                : Image.memory(
                    base64Decode(imageBase64!),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(imageBase64 == null ? 'Ambil bukti' : 'Ambil ulang'),
                onPressed: capturing ? null : onCapture,
              ),
            ),
            if (imageBase64 != null) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 56,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(56, 56),
                  ),
                  onPressed: onClear,
                  child: const Icon(Icons.delete_outline),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

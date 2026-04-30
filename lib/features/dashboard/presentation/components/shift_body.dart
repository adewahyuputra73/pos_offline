import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:border_po/models/shift.dart';
import 'package:border_po/models/transaction.dart';
import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';
import 'top_bar_widget.dart';

/// Halaman manajemen shift kasir.
/// - Jika tidak ada shift aktif: tampilkan tombol "Buka Shift" + riwayat.
/// - Jika ada shift aktif: tampilkan info & stats shift + tombol "Tutup Shift".
class ShiftBody extends StatelessWidget {
  final Widget? leading;
  const ShiftBody({super.key, this.leading});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      children: [
        TopBarWidget(
          leading: leading,
          title: 'Manajemen Shift',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Status shift aktif atau tombol buka ──────────────────────
                if (state.hasActiveShift)
                  _ActiveShiftCard(shift: state.activeShift!, state: state)
                else
                  _NoShiftCard(),

                const SizedBox(height: 24),

                // ── Riwayat shift ─────────────────────────────────────────────
                _ShiftHistorySection(state: state),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Card: tidak ada shift aktif ───────────────────────────────────────────────

class _NoShiftCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: DC.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_clock_outlined, size: 36, color: DC.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Shift Aktif',
            style: manrope(fontSize: 20, fontWeight: FontWeight.w800, color: DC.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Buka shift terlebih dahulu untuk mulai menerima transaksi.',
            style: manrope(fontSize: 13, color: DC.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: Text(
                'Buka Shift Baru',
                style: manrope(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DC.primary,
                foregroundColor: DC.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => _OpenShiftSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card: shift sedang aktif ──────────────────────────────────────────────────

class _ActiveShiftCard extends StatefulWidget {
  final Shift shift;
  final AppState state;
  const _ActiveShiftCard({required this.shift, required this.state});

  @override
  State<_ActiveShiftCard> createState() => _ActiveShiftCardState();
}

class _ActiveShiftCardState extends State<_ActiveShiftCard> {
  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final state = widget.state;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DC.primary, DC.primaryDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DC.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'SHIFT AKTIF',
                                  style: manrope(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shift.cashierName,
                        style: manrope(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Durasi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      shift.durationLabel,
                      style: manrope(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      'durasi shift',
                      style: manrope(fontSize: 10, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Waktu mulai ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Text(
                  'Dibuka: ${formatDateFull(shift.openedAt)}',
                  style: manrope(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Stats grid ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(builder: (ctx, c) {
              final items = [
                _StatData('Transaksi', '${state.activeShiftTransactionCount}', Icons.receipt_outlined),
                _StatData('Total Pendapatan', formatRupiah(state.activeShiftRevenue), Icons.payments_outlined),
                _StatData('Tunai', formatRupiah(state.activeShiftCashRevenue), Icons.money_outlined),
                _StatData('QRIS', formatRupiah(state.activeShiftQrisRevenue), Icons.qr_code_2_rounded),
                _StatData('Modal Awal', formatRupiah(shift.openingCash), Icons.account_balance_wallet_outlined),
                _StatData('Est. Kas', formatRupiah(state.activeShiftExpectedCash), Icons.savings_outlined),
              ];
              final cols = c.maxWidth > 500 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.2,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => _StatTile(data: items[i]),
              );
            }),
          ),

          const SizedBox(height: 20),

          // ── Tombol tutup shift ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle_outlined, size: 20),
              label: Text(
                'Tutup Shift',
                style: manrope(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: DC.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => _CloseShiftSheet.show(context, state),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  const _StatData(this.label, this.value, this.icon);
}

class _StatTile extends StatelessWidget {
  final _StatData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.label,
            style: manrope(fontSize: 9, fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7), letterSpacing: 0.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            data.value,
            style: manrope(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Riwayat Shift ─────────────────────────────────────────────────────────────

class _ShiftHistorySection extends StatelessWidget {
  final AppState state;
  const _ShiftHistorySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final closed = state.shifts.where((s) => !s.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_rounded, size: 18, color: DC.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'Riwayat Shift',
              style: manrope(fontSize: 16, fontWeight: FontWeight.w800, color: DC.onSurface),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DC.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${closed.length}',
                style: manrope(fontSize: 11, fontWeight: FontWeight.w700, color: DC.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (closed.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: DC.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Belum ada riwayat shift.',
                style: manrope(fontSize: 13, color: DC.onSurfaceVariant),
              ),
            ),
          )
        else
          ...closed.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ShiftHistoryTile(shift: s, state: state),
              )),
      ],
    );
  }
}

class _ShiftHistoryTile extends StatelessWidget {
  final Shift shift;
  final AppState state;
  const _ShiftHistoryTile({required this.shift, required this.state});

  @override
  Widget build(BuildContext context) {
    final rev = shift.snapshotRevenue ?? 0;
    final txCount = shift.snapshotTransactions ?? 0;
    final cashRev = shift.snapshotCash ?? 0;
    final qrisRev = shift.snapshotQris ?? 0;
    final closing = shift.closingCash ?? 0;
    final expected = shift.openingCash + cashRev;
    final selisih = closing - expected;

    return Container(
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DC.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.work_history_outlined, size: 20, color: DC.primary),
          ),
          title: Text(
            shift.cashierName,
            style: manrope(fontSize: 14, fontWeight: FontWeight.w700, color: DC.onSurface),
          ),
          subtitle: Text(
            '${formatDateShort(shift.openedAt)}  ·  ${shift.durationLabel}  ·  $txCount transaksi',
            style: manrope(fontSize: 11, color: DC.onSurfaceVariant),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(rev),
                style: manrope(fontSize: 14, fontWeight: FontWeight.w800, color: DC.primary),
              ),
              Text(
                'total',
                style: manrope(fontSize: 9, color: DC.onSurfaceVariant),
              ),
            ],
          ),
          children: [
            Divider(color: DC.outlineVariant.withValues(alpha: 0.3), height: 16),
            _HistoryRow('Waktu Buka', formatDateFull(shift.openedAt)),
            _HistoryRow('Waktu Tutup', formatDateFull(shift.closedAt!)),
            _HistoryRow('Durasi', shift.durationLabel),
            const SizedBox(height: 8),
            _HistoryRow('Modal Awal', formatRupiah(shift.openingCash)),
            _HistoryRow('Pendapatan Tunai', formatRupiah(cashRev)),
            _HistoryRow('Pendapatan QRIS', formatRupiah(qrisRev)),
            _HistoryRow('Total Pendapatan', formatRupiah(rev), bold: true),
            const SizedBox(height: 8),
            _HistoryRow('Estimasi Kas', formatRupiah(expected)),
            _HistoryRow('Kas Aktual', formatRupiah(closing)),
            _HistoryRow(
              'Selisih Kas',
              (selisih >= 0 ? '+' : '') + formatRupiah(selisih),
              valueColor: selisih == 0
                  ? DC.tertiary
                  : selisih > 0
                      ? DC.tertiary
                      : DC.error,
            ),
            if (shift.notes != null && shift.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _HistoryRow('Catatan', shift.notes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _HistoryRow(this.label, this.value, {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: manrope(fontSize: 12, color: DC.onSurfaceVariant)),
          Text(
            value,
            style: manrope(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? DC.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sheet: Buka Shift ─────────────────────────────────────────────────────────

class _OpenShiftSheet {
  static Future<void> show(BuildContext context) {
    final state = context.read<AppState>();
    final nameCtrl = TextEditingController();
    final cashCtrl = TextEditingController();

    return showModalBottomSheet<void>(
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
                // Handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: DC.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Buka Shift Baru',
                    style: manrope(fontSize: 20, fontWeight: FontWeight.w800, color: DC.onSurface)),
                Text('Isi data kasir dan uang awal di laci.',
                    style: manrope(fontSize: 13, color: DC.onSurfaceVariant)),
                const SizedBox(height: 24),

                _SheetField(controller: nameCtrl, label: 'Nama Kasir',
                    icon: Icons.person_outline_rounded, autofocus: true,
                    textCapitalization: TextCapitalization.words),
                const SizedBox(height: 12),
                _SheetField(
                  controller: cashCtrl,
                  label: 'Uang Awal di Laci (Rp)',
                  icon: Icons.account_balance_wallet_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 28),

                ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                  label: Text('Mulai Shift',
                      style: manrope(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DC.primary,
                    foregroundColor: DC.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final cash = int.tryParse(cashCtrl.text.trim()) ?? 0;
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text('Nama kasir wajib diisi.',
                            style: manrope(color: Colors.white)),
                        backgroundColor: DC.error,
                      ));
                      return;
                    }
                    await state.openShift(cashierName: name, openingCash: cash);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Sheet: Tutup Shift ────────────────────────────────────────────────────────

class _CloseShiftSheet {
  static Future<void> show(BuildContext context, AppState state) {
    final shift = state.activeShift!;
    final cashCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DC.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        return StatefulBuilder(builder: (ctx, setSheet) {
          final actualCash = int.tryParse(cashCtrl.text) ?? 0;
          final expectedCash = state.activeShiftExpectedCash;
          final selisih = actualCash - expectedCash;

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: DC.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Tutup Shift',
                      style: manrope(fontSize: 20, fontWeight: FontWeight.w800, color: DC.onSurface)),
                  Text('Rekap shift ${shift.cashierName} · ${shift.durationLabel}',
                      style: manrope(fontSize: 13, color: DC.onSurfaceVariant)),
                  const SizedBox(height: 20),

                  // ── Ringkasan shift ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DC.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow('Total Transaksi', '${state.activeShiftTransactionCount} transaksi'),
                        _SummaryRow('Pendapatan Tunai', formatRupiah(state.activeShiftCashRevenue)),
                        _SummaryRow('Pendapatan QRIS', formatRupiah(state.activeShiftQrisRevenue)),
                        const Divider(height: 16),
                        _SummaryRow('Total Pendapatan', formatRupiah(state.activeShiftRevenue), bold: true),
                        _SummaryRow('Estimasi Kas Tunai', formatRupiah(expectedCash)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Input kas aktual ─────────────────────────────────────────
                  _SheetField(
                    controller: cashCtrl,
                    label: 'Hitung Uang di Laci (Rp)',
                    icon: Icons.calculate_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setSheet(() {}),
                  ),

                  // ── Selisih kas ──────────────────────────────────────────────
                  if (cashCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selisih == 0
                            ? DC.tertiaryContainer
                            : selisih > 0
                                ? DC.tertiaryContainer
                                : DC.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Selisih Kas',
                              style: manrope(fontSize: 13, fontWeight: FontWeight.w600,
                                  color: DC.onSurface)),
                          Text(
                            (selisih >= 0 ? '+' : '') + formatRupiah(selisih),
                            style: manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: selisih >= 0 ? DC.tertiary : DC.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  _SheetField(
                    controller: notesCtrl,
                    label: 'Catatan (opsional)',
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop_circle_outlined, size: 20),
                    label: Text('Konfirmasi Tutup Shift',
                        style: manrope(fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DC.primary,
                      foregroundColor: DC.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final cash = int.tryParse(cashCtrl.text.trim()) ?? 0;
                      await state.closeShift(
                        closingCash: cash,
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                      );
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: manrope(fontSize: 12, color: DC.onSurfaceVariant)),
          Text(value,
              style: manrope(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: DC.onSurface)),
        ],
      ),
    );
  }
}

// ── Reusable styled text field ────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.onChanged,
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
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        onChanged: onChanged,
        style: manrope(fontSize: 14, color: DC.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: manrope(fontSize: 14, color: DC.onSurfaceVariant.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, size: 20, color: DC.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

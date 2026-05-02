import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

enum HppDateFilter { today, last7, last30, all }

extension HppDateFilterExt on HppDateFilter {
  String get label {
    switch (this) {
      case HppDateFilter.today:
        return 'Hari Ini';
      case HppDateFilter.last7:
        return '7 Hari Terakhir';
      case HppDateFilter.last30:
        return '30 Hari Terakhir';
      case HppDateFilter.all:
        return 'Semua Waktu';
    }
  }
}

class HppReportBody extends StatefulWidget {
  final Widget? leading;
  const HppReportBody({super.key, this.leading});

  @override
  State<HppReportBody> createState() => _HppReportBodyState();
}

class _HppReportBodyState extends State<HppReportBody> {
  HppDateFilter _filter = HppDateFilter.today;
  String _searchQuery = '';

  int _sortColumnIndex = 1; // Default sort by Qty
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    DateTime? from;
    final now = DateTime.now();
    switch (_filter) {
      case HppDateFilter.today:
        from = DateTime(now.year, now.month, now.day);
        break;
      case HppDateFilter.last7:
        from = now.subtract(const Duration(days: 7));
        break;
      case HppDateFilter.last30:
        from = now.subtract(const Duration(days: 30));
        break;
      case HppDateFilter.all:
        from = null;
        break;
    }

    final hppData = state.hppReport(from: from).values.toList();

    // Calculate totals based on all data in the period (before search filter)
    int totalRev = 0;
    int totalCogs = 0;
    int totalProfit = 0;
    for (final p in hppData) {
      totalRev += p.totalRevenue;
      totalCogs += p.totalCogs;
      totalProfit += p.totalProfit;
    }
    double avgMargin = totalRev > 0 ? (totalProfit / totalRev) * 100 : 0.0;

    // Filter by search
    final filteredData = hppData.where((p) {
      return _searchQuery.isEmpty ||
          p.productName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sorting
    filteredData.sort((a, b) {
      int cmp = 0;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.productName.compareTo(b.productName);
          break;
        case 1:
          cmp = a.totalQuantitySold.compareTo(b.totalQuantitySold);
          break;
        case 2:
          cmp = a.pricePerUnit.compareTo(b.pricePerUnit);
          break;
        case 3:
          cmp = a.cogsPerUnit.compareTo(b.cogsPerUnit);
          break;
        case 4:
          cmp = a.profitPerUnit.compareTo(b.profitPerUnit);
          break;
        case 5:
          cmp = a.totalRevenue.compareTo(b.totalRevenue);
          break;
        case 6:
          cmp = a.totalCogs.compareTo(b.totalCogs);
          break;
        case 7:
          cmp = a.totalProfit.compareTo(b.totalProfit);
          break;
        case 8:
          cmp = a.marginPercent.compareTo(b.marginPercent);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 800;

        return Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: DC.surfaceContainerLowest,
                border: Border(
                  bottom: BorderSide(
                    color: DC.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 16),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAPORAN',
                        style: manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: DC.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HPP & Profit Margin',
                        style: manrope(
                          fontSize: compact ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: DC.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: DC.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<HppDateFilter>(
                        value: _filter,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                        style: manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DC.onSurface,
                        ),
                        items: HppDateFilter.values.map((f) {
                          return DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _filter = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(compact ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryCards(compact, totalRev, totalCogs, totalProfit, avgMargin),
                    SizedBox(height: compact ? 16 : 24),
                    _buildTableSection(compact, filteredData),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(bool compact, int rev, int cogs, int profit, double margin) {
    final cards = [
      _SummaryBox(
        title: 'Total Pendapatan',
        value: formatRupiah(rev),
        icon: Icons.payments_outlined,
        color: DC.primary,
        bgColor: DC.primaryContainer,
      ),
      _SummaryBox(
        title: 'Total HPP (Modal)',
        value: formatRupiah(cogs),
        icon: Icons.inventory_2_outlined,
        color: DC.error,
        bgColor: DC.error.withValues(alpha: 0.1),
      ),
      _SummaryBox(
        title: 'Laba Kotor',
        value: formatRupiah(profit),
        icon: Icons.trending_up_rounded,
        color: DC.tertiary,
        bgColor: DC.tertiaryContainer,
      ),
      _SummaryBox(
        title: 'Margin Rata-rata',
        value: '${margin.toStringAsFixed(1)}%',
        icon: Icons.pie_chart_outline,
        color: _getMarginColor(margin),
        bgColor: _getMarginColor(margin).withValues(alpha: 0.1),
      ),
    ];

    if (compact) {
      return Column(
        children: [
          Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
        ],
      );
    }

    return Row(
      children: cards.map((c) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: c != cards.last ? 16.0 : 0),
          child: c,
        ),
      )).toList(),
    );
  }

  Widget _buildTableSection(bool compact, List<ProductHppSummary> data) {
    return Container(
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header Controls
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Breakdown Per Produk',
                  style: manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: DC.onSurface,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 240,
                  height: 40,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: manrope(
                        fontSize: 13,
                        color: DC.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(Icons.search_rounded, size: 18, color: DC.onSurfaceVariant),
                      filled: true,
                      fillColor: DC.surfaceContainerHigh,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DC.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
              dataTextStyle: manrope(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: DC.onSurface,
              ),
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columnSpacing: 24,
              columns: [
                DataColumn(label: const Text('PRODUK'), onSort: _onSort),
                DataColumn(label: const Text('TERJUAL'), numeric: true, onSort: _onSort),
                // ── Per Unit columns ─────────────────────────────
                DataColumn(label: const Text('HARGA/UNIT'), numeric: true, onSort: _onSort),
                DataColumn(label: const Text('HPP/UNIT'), numeric: true, onSort: _onSort),
                DataColumn(label: const Text('PROFIT/UNIT'), numeric: true, onSort: _onSort),
                // ── Total columns ────────────────────────────────
                DataColumn(label: const Text('TOTAL PENDAPATAN'), numeric: true, onSort: _onSort),
                DataColumn(label: const Text('TOTAL HPP'), numeric: true, onSort: _onSort),
                DataColumn(label: const Text('TOTAL LABA'), numeric: true, onSort: _onSort),
                DataColumn(label: const Text('MARGIN'), numeric: true, onSort: _onSort),
              ],
              rows: data.map((p) {
                final marginColor = _getMarginColor(p.marginPercent);
                final profitColor = p.profitPerUnit > 0 ? DC.tertiary : DC.error;
                return DataRow(
                  cells: [
                    DataCell(Text(p.productName, style: manrope(fontWeight: FontWeight.w700))),
                    DataCell(Text('${p.totalQuantitySold}x')),
                    // Per-unit cells
                    DataCell(Text(formatRupiah(p.pricePerUnit))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: DC.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formatRupiah(p.cogsPerUnit),
                          style: manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DC.error,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatRupiah(p.profitPerUnit),
                        style: manrope(fontWeight: FontWeight.w700, color: profitColor),
                      ),
                    ),
                    // Total cells
                    DataCell(Text(formatRupiah(p.totalRevenue), style: manrope(color: DC.onSurfaceVariant))),
                    DataCell(Text(formatRupiah(p.totalCogs), style: manrope(color: DC.error.withValues(alpha: 0.7)))),
                    DataCell(Text(formatRupiah(p.totalProfit), style: manrope(fontWeight: FontWeight.w700, color: DC.tertiary))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: marginColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${p.marginPercent.toStringAsFixed(1)}%',
                          style: manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: marginColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: Center(
                child: Text(
                  'Tidak ada data untuk periode ini.',
                  style: manrope(color: DC.onSurfaceVariant),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Color _getMarginColor(double margin) {
    if (margin >= 40) return DC.tertiary; // Healthy profit
    if (margin >= 20) return const Color(0xFFF57F17); // Yellow/Orange
    return DC.error; // Low margin
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DC.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DC.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DC.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: DC.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

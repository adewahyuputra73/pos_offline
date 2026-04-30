import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../theme/dashboard_colors.dart';

/// Sales Performance chart — reads real transaction data from [AppState].
///
/// Supports toggling between revenue-per-day and transaction-count-per-day
/// for the last 7 days.
class SalesChartWidget extends StatefulWidget {
  const SalesChartWidget({super.key});

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  String _mode = 'REVENUE'; // 'REVENUE' or 'TRANSAKSI'

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bars = _buildBars(state);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 400;
        final double pad = compact ? 16 : 32;
        final bool hasBoundedHeight = constraints.maxHeight.isFinite;

        // The chart area widget
        Widget chartArea = LayoutBuilder(
          builder: (context, boxConstraints) {
            if (bars.isEmpty || bars.every((b) => b.value == 0)) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 40, color: DC.onSurfaceVariant.withValues(alpha: 0.3)),
                    const SizedBox(height: 8),
                    Text('Belum ada data', style: manrope(fontSize: 13, color: DC.onSurfaceVariant.withValues(alpha: 0.5))),
                  ],
                ),
              );
            }
            final maxVal = bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (_) => Divider(height: 1, thickness: 1, color: DC.surfaceContainer)),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    key: ValueKey(_mode),
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: bars.map((b) => _BarWidget(bar: b, maxValue: maxVal, chartHeight: boxConstraints.maxHeight, isRevenue: _mode == 'REVENUE')).toList(),
                  ),
                ),
              ],
            );
          },
        );

        // Day labels
        Widget dayLabels = AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Row(
            key: ValueKey('${_mode}_labels'),
            children: bars.map((b) => Expanded(
              child: Text(b.day, textAlign: TextAlign.center, style: manrope(fontSize: compact ? 8 : 10, fontWeight: FontWeight.w700, letterSpacing: compact ? 0.8 : 1.4, color: DC.onSurfaceVariant.withValues(alpha: 0.5))),
            )).toList(),
          ),
        );

        // Header widgets (title, subtitle, mode buttons)
        List<Widget> headerWidgets = [
          Text(
            'Performa Penjualan',
            style: manrope(fontSize: compact ? 16 : 20, fontWeight: FontWeight.w700, color: DC.deepBrown),
          ),
          const SizedBox(height: 4),
          Text(
            '7 hari terakhir',
            style: manrope(fontSize: compact ? 11 : 13, color: DC.onSurfaceVariant.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['REVENUE', 'TRANSAKSI'].map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PeriodBtn(
                  label: p == 'REVENUE' ? 'Pendapatan' : 'Jumlah',
                  selected: p == _mode,
                  onTap: () => setState(() => _mode = p),
                  compact: compact,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: compact ? 12 : 24),
        ];

        return Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: DC.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: DC.deepBrown.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: hasBoundedHeight
              // BOUNDED: Use Expanded so chart fills remaining space
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...headerWidgets,
                    Expanded(child: chartArea),
                    SizedBox(height: compact ? 8 : 16),
                    dayLabels,
                  ],
                )
              // UNBOUNDED (inside ScrollView): Use fixed height
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...headerWidgets,
                    SizedBox(
                      height: (MediaQuery.of(context).size.height * 0.28).clamp(150.0, 280.0),
                      child: chartArea,
                    ),
                    SizedBox(height: compact ? 8 : 16),
                    dayLabels,
                  ],
                ),
        );
      },
    );
  }

  List<_Bar> _buildBars(AppState state) {
    final now = DateTime.now();
    final dayFmt = DateFormat('E', 'id_ID');
    final bars = <_Bar>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayTxs = state.transactions.where((t) =>
          t.createdAt.year == date.year &&
          t.createdAt.month == date.month &&
          t.createdAt.day == date.day);

      final int revenue = dayTxs.fold(0, (s, t) => s + t.total);
      final int count = dayTxs.length;

      bars.add(_Bar(
        day: dayFmt.format(date).toUpperCase(),
        value: _mode == 'REVENUE' ? revenue.toDouble() : count.toDouble(),
        label: _mode == 'REVENUE' ? formatRupiah(revenue) : '$count transaksi',
      ));
    }
    return bars;
  }
}

class _Bar {
  final String day;
  final double value;
  final String label;
  const _Bar({required this.day, required this.value, required this.label});
}

class _BarWidget extends StatefulWidget {
  final _Bar bar;
  final double maxValue;
  final double chartHeight;
  final bool isRevenue;
  const _BarWidget({required this.bar, required this.maxValue, required this.chartHeight, required this.isRevenue});

  @override
  State<_BarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends State<_BarWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool compact = widget.chartHeight < 250;
    final double tooltipReserve = compact ? 24 : 30;
    final double maxBarHeight = widget.chartHeight - tooltipReserve;
    final double ratio = widget.maxValue > 0 ? widget.bar.value / widget.maxValue : 0;
    final double barHeight = (maxBarHeight * ratio).clamp(4, maxBarHeight);

    final Color barColor = _hovered
        ? DC.primary
        : ratio > 0.8
            ? DC.primary.withValues(alpha: 0.4)
            : DC.primary.withValues(alpha: 0.2);

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: tooltipReserve,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _hovered ? 1.0 : 0.0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8, vertical: compact ? 2 : 4),
                      decoration: BoxDecoration(color: DC.onSurface, borderRadius: BorderRadius.circular(4)),
                      child: Text(widget.bar.label, style: manrope(fontSize: compact ? 8 : 10, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: widget.bar.value > 0 ? barHeight : 4,
                decoration: BoxDecoration(
                  color: widget.bar.value > 0 ? barColor : DC.primaryContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _PeriodBtn({required this.label, required this.selected, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DC.surfaceContainerHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16, vertical: compact ? 6 : 8),
          child: Text(label, style: manrope(fontSize: compact ? 9 : 11, fontWeight: FontWeight.w700, color: selected ? DC.onSurface : DC.onSurfaceVariant.withValues(alpha: 0.6))),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Sales Performance chart — mirrors the `lg:col-span-2` section in the HTML.
///
/// Implements a pure-Flutter bar chart (no third-party lib) using [Column]
/// + [AnimatedContainer] bars with hover tooltips via [MouseRegion].
///
/// NOTE: For production, replace with `fl_chart` (LineChart/BarChart) for
/// proper axes, animations, and touch interactions. This widget is a
/// pixel-faithful stand-in for the design review phase.
class SalesChartWidget extends StatefulWidget {
  const SalesChartWidget({super.key});

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  String _period = 'WEEKLY';

  static const _weeklyBars = <_BarData>[
    _BarData(day: 'Mon', ratio: 0.60, label: '\$420'),
    _BarData(day: 'Tue', ratio: 0.45, label: '\$315'),
    _BarData(day: 'Wed', ratio: 0.85, label: '\$595'),
    _BarData(day: 'Thu', ratio: 0.70, label: '\$490'),
    _BarData(day: 'Fri', ratio: 0.95, label: '\$665', highlight: true),
    _BarData(day: 'Sat', ratio: 0.50, label: '\$350'),
    _BarData(day: 'Sun', ratio: 0.30, label: '\$210'),
  ];

  static const _monthlyBars = <_BarData>[
    _BarData(day: 'W1', ratio: 0.55, label: '\$3.1k'),
    _BarData(day: 'W2', ratio: 0.75, label: '\$4.2k'),
    _BarData(day: 'W3', ratio: 0.90, label: '\$5.0k', highlight: true),
    _BarData(day: 'W4', ratio: 0.65, label: '\$3.7k'),
  ];

  List<_BarData> get _bars =>
      _period == 'WEEKLY' ? _weeklyBars : _monthlyBars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Performance',
                      style: manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: DC.deepBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Weekly overview of revenue stream',
                      style: manrope(
                        fontSize: 13,
                        color: DC.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Period toggle
              Row(
                children: ['WEEKLY', 'MONTHLY'].map((p) {
                  final selected = p == _period;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _PeriodButton(
                      label: p,
                      selected: selected,
                      onTap: () => setState(() => _period = p),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ── Bar chart ───────────────────────────────────────────────────────
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                // Horizontal grid lines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (_) => Divider(
                      height: 1,
                      color: DC.surfaceContainer,
                    ),
                  ),
                ),
                // Bars
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _bars
                      .map((b) => _AnimatedBar(data: b))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Day labels ──────────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Row(
              key: ValueKey(_period),
              children: _bars
                  .map(
                    (b) => Expanded(
                      child: Text(
                        b.day,
                        textAlign: TextAlign.center,
                        style: manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color:
                              DC.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data + sub-widgets ────────────────────────────────────────────────────────

class _BarData {
  final String day;
  final double ratio; // 0.0–1.0 relative to chart height
  final String label; // tooltip text
  final bool highlight;

  const _BarData({
    required this.day,
    required this.ratio,
    required this.label,
    this.highlight = false,
  });
}

class _AnimatedBar extends StatefulWidget {
  final _BarData data;
  const _AnimatedBar({required this.data});

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 260.0;
    final barH = chartHeight * widget.data.ratio;
    final Color barColor = _hovered
        ? DC.primary
        : widget.data.highlight
            ? DC.primary.withValues(alpha: 0.4)
            : DC.primary.withValues(alpha: 0.2);

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tooltip chip
              AnimatedOpacity(
                duration: const Duration(milliseconds: 140),
                opacity: _hovered ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DC.stone900,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${widget.data.day}: ${widget.data.label}',
                    style: manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Bar itself
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: barH,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DC.surfaceContainerHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: selected
                  ? DC.onSurface
                  : DC.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Sales Performance section — `<div class="lg:col-span-2 bg-surface-container-lowest p-8 rounded-xl">`.
///
/// Bar heights and colors match exactly the HTML source:
///   Mon 60%, Tue 45%, Wed 85%, Thu 70%, Fri 95% (primary/40), Sat 50%, Sun 30% (primary-container)
class SalesChartWidget extends StatefulWidget {
  const SalesChartWidget({super.key});

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  String _period = 'WEEKLY';

  /// HTML bar definitions — ratio = percentage height from the HTML classes.
  static const _weeklyBars = <_Bar>[
    _Bar(day: 'MON', ratio: 0.60, label: 'Mon: \$420', style: _BarStyle.normal),
    _Bar(day: 'TUE', ratio: 0.45, label: 'Tue: \$315', style: _BarStyle.normal),
    _Bar(day: 'WED', ratio: 0.85, label: 'Wed: \$595', style: _BarStyle.normal),
    _Bar(day: 'THU', ratio: 0.70, label: 'Thu: \$490', style: _BarStyle.normal),
    // HTML: bg-primary/40 (highlighted, not primary/20)
    _Bar(day: 'FRI', ratio: 0.95, label: 'Fri: \$665', style: _BarStyle.highlight),
    _Bar(day: 'SAT', ratio: 0.50, label: 'Sat: \$350', style: _BarStyle.normal),
    // HTML: bg-primary-container (lightest tone, not primary/20)
    _Bar(day: 'SUN', ratio: 0.30, label: 'Sun: \$210', style: _BarStyle.container),
  ];

  static const _monthlyBars = <_Bar>[
    _Bar(day: 'W1', ratio: 0.55, label: 'Week 1: \$3.1k', style: _BarStyle.normal),
    _Bar(day: 'W2', ratio: 0.72, label: 'Week 2: \$4.0k', style: _BarStyle.normal),
    _Bar(day: 'W3', ratio: 0.92, label: 'Week 3: \$5.1k', style: _BarStyle.highlight),
    _Bar(day: 'W4', ratio: 0.65, label: 'Week 4: \$3.6k', style: _BarStyle.normal),
  ];

  List<_Bar> get _bars => _period == 'WEEKLY' ? _weeklyBars : _monthlyBars;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 400;
        final double pad = compact ? 16 : 32;
        final double chartHeight = compact ? 180 : 300;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Performance',
                    style: manrope(
                      fontSize: compact ? 16 : 20,
                      fontWeight: FontWeight.w700,
                      color: DC.deepBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Weekly overview of revenue stream',
                    style: manrope(
                      fontSize: compact ? 11 : 13,
                      color: DC.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Period toggle buttons — always in a row, compact sizing
                  Row(
                    children: ['WEEKLY', 'MONTHLY'].map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _PeriodBtn(
                          label: p,
                          selected: p == _period,
                          onTap: () => setState(() => _period = p),
                          compact: compact,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              SizedBox(height: compact ? 20 : 40),

              // ── Chart area ────────────────────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              4,
                              (_) => Divider(
                                height: 1,
                                thickness: 1,
                                color: DC.surfaceContainer,
                              ),
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Row(
                            key: ValueKey(_period),
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _bars
                                .map((b) => _BarWidget(
                                    bar: b, chartHeight: boxConstraints.maxHeight))
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),

              // ── Day labels ────────────────────────────────────────────────
              SizedBox(height: compact ? 12 : 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Row(
                  key: ValueKey('${_period}_labels'),
                  children: _bars
                      .map(
                        (b) => Expanded(
                          child: Text(
                            b.day,
                            textAlign: TextAlign.center,
                            style: manrope(
                              fontSize: compact ? 8 : 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: compact ? 0.8 : 1.4,
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
      },
    );
  }
}

// ── Bar data ──────────────────────────────────────────────────────────────────

enum _BarStyle { normal, highlight, container }

class _Bar {
  final String day;
  final double ratio;
  final String label;
  final _BarStyle style;
  const _Bar({
    required this.day,
    required this.ratio,
    required this.label,
    required this.style,
  });
}

class _BarWidget extends StatefulWidget {
  final _Bar bar;
  final double chartHeight;
  const _BarWidget({required this.bar, this.chartHeight = 300});

  @override
  State<_BarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends State<_BarWidget> {
  bool _hovered = false;

  Color get _baseColor {
    if (_hovered) return DC.primary; // HTML: hover:bg-primary
    switch (widget.bar.style) {
      case _BarStyle.highlight:
        return DC.primary.withValues(alpha: 0.4); // bg-primary/40
      case _BarStyle.container:
        return DC.primaryContainer; // bg-primary-container
      case _BarStyle.normal:
      default:
        return DC.primary.withValues(alpha: 0.2); // bg-primary/20
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = widget.chartHeight < 250;
    // Reserve space for tooltip so bars never overflow
    final double tooltipReserve = compact ? 24 : 30;
    final double maxBarHeight = widget.chartHeight - tooltipReserve;
    final double barHeight = maxBarHeight * widget.bar.ratio;

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
              // Tooltip — fixed height reserve so it doesn't push bars out
              SizedBox(
                height: tooltipReserve,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _hovered ? 1.0 : 0.0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 4 : 8,
                        vertical: compact ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: DC.onSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.bar.label,
                        style: manrope(
                          fontSize: compact ? 8 : 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // The bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: barHeight,
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Period toggle button ──────────────────────────────────────────────────────

class _PeriodBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _PeriodBtn({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
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
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 16,
            vertical: compact ? 6 : 8,
          ),
          child: Text(
            label,
            style: manrope(
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w700,
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

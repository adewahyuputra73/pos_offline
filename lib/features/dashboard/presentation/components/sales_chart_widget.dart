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
          // ── Header row ──────────────────────────────────────────────────────
          // HTML: flex items-center justify-between mb-10
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HTML: text-xl font-bold text-[#2d2514]
                    Text(
                      'Sales Performance',
                      style: manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: DC.deepBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // HTML: text-sm text-on-surface-variant/70
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
              // HTML: flex gap-2 — period toggle buttons
              Row(
                children: ['WEEKLY', 'MONTHLY'].map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _PeriodBtn(
                      label: p,
                      selected: p == _period,
                      onTap: () => setState(() => _period = p),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ── Chart area — HTML: relative h-[300px] ──────────────────────────
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // HTML: absolute inset-0 — 4 horizontal grid lines
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
                // Bars row
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    key: ValueKey(_period),
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _bars
                        .map((b) => _BarWidget(bar: b))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Day labels — HTML: flex justify-between mt-6 ──────────────────
          const SizedBox(height: 24),
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
                        // HTML: text-[10px] font-bold text-on-surface-variant/50 tracking-widest uppercase
                        style: manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
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
  const _BarWidget({required this.bar});

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
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tooltip — HTML: opacity-0 group-hover:opacity-100
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _hovered ? 1.0 : 0.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    // HTML: bg-on-surface text-white
                    color: DC.onSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.bar.label,
                    style: manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // The bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 300 * widget.bar.ratio,
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

  const _PeriodBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // HTML: bg-surface-container-high rounded-full (active) | transparent (inactive)
      color: selected ? DC.surfaceContainerHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          // HTML: px-4 py-2
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: manrope(
              // HTML: text-xs font-bold
              fontSize: 11,
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

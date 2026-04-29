import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/state/app_state.dart';
import '../theme/dashboard_colors.dart';

/// Local storage status card — shows counts of stored data.
///
/// Replaces the old server-connectivity card with relevant offline-mode info.
class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 360;
        final double pad = compact ? 16 : 32;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(pad),
            color: DC.stone900,
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 256,
                    height: 256,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DC.primaryDim.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PENYIMPANAN LOKAL',
                            style: manrope(
                              fontSize: compact ? 9 : 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: DC.primaryFixedDim,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mode Offline — Aktif',
                            style: manrope(
                              fontSize: compact ? 16 : 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatusDot(label: '${state.products.length} Produk tersimpan'),
                              const SizedBox(height: 8),
                              _StatusDot(label: '${state.categories.length} Kategori tersimpan'),
                              const SizedBox(height: 8),
                              _StatusDot(label: '${state.transactions.length} Transaksi tercatat'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.smartphone_rounded,
                          size: 28,
                          color: DC.primaryFixedDim,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusDot extends StatefulWidget {
  final String label;
  const _StatusDot({required this.label});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _anim,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: DC.tertiary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            widget.label,
            style: manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DC.stone400,
            ),
          ),
        ),
      ],
    );
  }
}

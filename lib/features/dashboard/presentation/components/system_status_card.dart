import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// `<div class="bg-stone-900 rounded-xl p-8 text-white flex items-center gap-8 relative overflow-hidden">`
///
/// Dark card with pulsing status dots and a decorative glow in the top-right.
class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                            'System Health',
                            style: manrope(
                              fontSize: compact ? 9 : 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: DC.primaryFixedDim,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Store connectivity is excellent',
                            style: manrope(
                              fontSize: compact ? 16 : 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PulsingDot(label: 'Main Server: Active'),
                              SizedBox(height: 8),
                              _PulsingDot(label: 'Payment Gateway: Online'),
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
                          Icons.hub_rounded,
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

// ── Pulsing status indicator ──────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  final String label;
  const _PulsingDot({required this.label});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
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
        // HTML: w-2 h-2 rounded-full bg-tertiary animate-pulse
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
        // HTML: text-xs font-medium text-stone-400
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

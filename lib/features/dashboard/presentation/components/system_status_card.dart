import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// `<div class="bg-stone-900 rounded-xl p-8 text-white flex items-center gap-8 relative overflow-hidden">`
///
/// Dark card with pulsing status dots and a decorative glow in the top-right.
class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // HTML: p-8
        padding: const EdgeInsets.all(32),
        color: DC.stone900,
        child: Stack(
          children: [
            // ── Decorative glow — HTML: absolute top-0 right-0 w-64 h-64
            //    bg-primary-dim/20 blur-[80px] rounded-full translate-x-1/2 -translate-y-1/2
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

            // ── Content — HTML: flex items-center gap-8
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // HTML: text-xs font-bold text-primary-fixed-dim uppercase tracking-widest mb-2
                      Text(
                        'System Health',
                        style: manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: DC.primaryFixedDim,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // HTML: text-2xl font-bold mb-4
                      Text(
                        'Store connectivity is excellent',
                        style: manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // HTML: flex items-center gap-6
                      Wrap(
                        spacing: 24,
                        runSpacing: 8,
                        children: const [
                          _PulsingDot(label: 'Main Server: Active'),
                          _PulsingDot(label: 'Payment Gateway: Online'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),

                // Hub icon circle
                // HTML: p-6 rounded-full bg-white/5 backdrop-blur-xl border border-white/10
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.hub_rounded,
                    size: 40,
                    color: DC.primaryFixedDim,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
        Text(
          widget.label,
          style: manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: DC.stone400,
          ),
        ),
      ],
    );
  }
}

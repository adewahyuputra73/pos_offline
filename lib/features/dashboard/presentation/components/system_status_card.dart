import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Dark "System Health" card — mirrors the `bg-stone-900` div in the HTML.
///
/// Uses a pulsing dot animation for each status indicator, matching the
/// Tailwind `animate-pulse` class.
class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(32),
        color: DC.stone900,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative background glow (top-right)
            Positioned(
              top: -64,
              right: -64,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DC.primaryDim.withValues(alpha: 0.18),
                ),
              ),
            ),

            // Foreground content
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM HEALTH',
                        style: manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: DC.primaryFixedDim,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Store connectivity\nis excellent',
                        style: manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _PulsingStatus(label: 'Main Server: Active'),
                      const SizedBox(height: 10),
                      const _PulsingStatus(label: 'Payment Gateway: Online'),
                    ],
                  ),
                ),
                const SizedBox(width: 32),

                // Hub icon in frosted circle
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Icon(
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

class _PulsingStatus extends StatefulWidget {
  final String label;

  const _PulsingStatus({required this.label});

  @override
  State<_PulsingStatus> createState() => _PulsingStatusState();
}

class _PulsingStatusState extends State<_PulsingStatus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FadeTransition(
          opacity: _fade,
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

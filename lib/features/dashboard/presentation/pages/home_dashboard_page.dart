import 'package:flutter/material.dart';

import '../components/recent_transactions_widget.dart';
import '../components/sales_chart_widget.dart';
import '../components/sidebar_widget.dart';
import '../components/summary_card.dart';
import '../components/system_status_card.dart';
import '../components/top_bar_widget.dart';
import '../components/top_selling_card.dart';
import '../theme/dashboard_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HomeDashboardPage — pixel-faithful Flutter conversion of the Stitch HTML.
///
/// LAYOUT:
///   Always renders a sidebar (w=256) + scrollable main content in a Row.
///   On narrow screens the sidebar becomes a Drawer accessed via a hamburger.
///   The breakpoint (720dp) is deliberately low to match the Stitch desktop feel
///   on most Android tablets running landscape.
/// ─────────────────────────────────────────────────────────────────────────────
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  NavItem _activeNav = NavItem.dashboard;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 720;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: DC.background,
          drawer: isWide
              ? null
              : Drawer(
                  backgroundColor: DC.stone100,
                  child: SidebarWidget(
                    selected: _activeNav,
                    onSelected: (n) {
                      setState(() => _activeNav = n);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
          floatingActionButton: _DashFab(),
          body: Row(
            children: [
              // ── Permanent sidebar on wide screens ──────────────────────────
              if (isWide)
                SidebarWidget(
                  selected: _activeNav,
                  onSelected: (n) => setState(() => _activeNav = n),
                ),

              // ── Main column ────────────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    TopBarWidget(
                      leading: isWide
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.menu_rounded,
                                  color: DC.stone900),
                              onPressed: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: const _DashboardBody(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _DashFab extends StatefulWidget {
  @override
  State<_DashFab> createState() => _DashFabState();
}

class _DashFabState extends State<_DashFab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: DC.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DC.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _hovered ? 0.25 : 0,
            child: const Icon(Icons.add_rounded,
                color: DC.onPrimary, size: 32),
          ),
        ),
      ),
    );
  }
}

// ── Dashboard body — all sections ─────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SummarySection(),
        SizedBox(height: 32),
        _MainGridSection(),
        SizedBox(height: 32),
        _BottomSection(),
        SizedBox(height: 48), // FAB clearance
      ],
    );
  }
}

// ── Section 1: 3 bento summary cards ─────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final cards = _buildCards();
        if (c.maxWidth < 520) {
          // Single column stack
          return Column(
            children: cards
                .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: w,
                    ))
                .toList(),
          );
        }
        // 3-column row
        return Row(
          children: List.generate(cards.length, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < cards.length - 1 ? 20 : 0),
                child: cards[i],
              ),
            );
          }),
        );
      },
    );
  }

  List<Widget> _buildCards() => [
        _HoverCard(
          child: SummaryCard(
            icon: Icons.payments_outlined,
            iconBg: DC.primaryContainer,
            iconColor: DC.onPrimaryContainer,
            label: "TODAY'S REVENUE",
            value: '\$2,840.50',
            subtitle: TrendSubtitle(
              text: '+12.5% from yesterday',
              icon: Icons.trending_up_rounded,
              color: DC.tertiary,
            ),
          ),
        ),
        _HoverCard(
          child: SummaryCard(
            icon: Icons.receipt_long_outlined,
            iconBg: DC.secondaryContainer,
            iconColor: DC.onSecondaryContainer,
            label: 'TRANSACTIONS',
            value: '142',
            subtitle: const InfoSubtitle(
              text: 'Last sync: 2m ago',
              icon: Icons.schedule_rounded,
            ),
          ),
        ),
        _HoverCard(
          child: SummaryCard(
            icon: Icons.inventory_outlined,
            iconBg: DC.tertiaryContainer,
            iconColor: DC.onTertiaryContainer,
            label: 'INVENTORY ITEMS',
            value: '86',
            subtitle: TrendSubtitle(
              text: '4 items low in stock',
              icon: Icons.warning_amber_rounded,
              color: DC.error,
            ),
          ),
        ),
      ];
}

/// Replicates Tailwind `hover:translate-y-[-2px] transition-transform`.
class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        child: widget.child,
      ),
    );
  }
}

// ── Section 2: Sales Chart (2/3) + Recent Transactions (1/3) ─────────────────

class _MainGridSection extends StatelessWidget {
  const _MainGridSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        if (c.maxWidth < 720) {
          return const Column(
            children: [
              SalesChartWidget(),
              SizedBox(height: 24),
              RecentTransactionsWidget(),
            ],
          );
        }
        return const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: SalesChartWidget()),
              SizedBox(width: 24),
              Expanded(flex: 1, child: RecentTransactionsWidget()),
            ],
          ),
        );
      },
    );
  }
}

// ── Section 3: System Status + Top Selling ────────────────────────────────────

class _BottomSection extends StatelessWidget {
  const _BottomSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        if (c.maxWidth < 640) {
          return const Column(
            children: [
              SystemStatusCard(),
              SizedBox(height: 24),
              TopSellingCard(),
            ],
          );
        }
        return const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: SystemStatusCard()),
              SizedBox(width: 24),
              Expanded(child: TopSellingCard()),
            ],
          ),
        );
      },
    );
  }
}

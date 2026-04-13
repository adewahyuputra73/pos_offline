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
/// HomeDashboardPage
///
/// Converts the HTML Barista POS dashboard into a Flutter widget tree.
///
/// LAYOUT STRATEGY
/// ───────────────
///  ≥ 1024 dp  →  Row { SidebarWidget (256) | Column { TopBar + Scrollable } }
///  < 1024 dp  →  Scaffold Drawer { SidebarWidget } + hamburger in TopBar
///
/// All content is wrapped in a [SingleChildScrollView] so the page works on
/// both large displays and smaller tablets without overflow.
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
        final bool isWide = constraints.maxWidth >= 1024;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: DC.background,

          // ── Narrow: sidebar lives in a Drawer ──────────────────────────────
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

          // ── FAB ────────────────────────────────────────────────────────────
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: DC.primary,
            foregroundColor: DC.onPrimary,
            elevation: 10,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, size: 30),
          ),

          body: Row(
            children: [
              // ── Wide: inline sidebar ───────────────────────────────────────
              if (isWide)
                SidebarWidget(
                  selected: _activeNav,
                  onSelected: (n) => setState(() => _activeNav = n),
                ),

              // ── Main content column ────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    // Sticky top bar
                    TopBarWidget(
                      leading: isWide
                          ? null
                          : IconButton(
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: DC.stone900,
                              ),
                              onPressed: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            ),
                    ),

                    // Scrollable page body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _SummarySection(),
                            SizedBox(height: 32),
                            _MainGrid(),
                            SizedBox(height: 32),
                            _BottomSection(),
                            // Extra bottom breathing room for FAB
                            SizedBox(height: 48),
                          ],
                        ),
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

// ── Section widgets ───────────────────────────────────────────────────────────

/// Three bento summary cards in a responsive grid.
class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Collapse to single column on very narrow viewports
        final bool singleCol = c.maxWidth < 520;
        return singleCol
            ? Column(
                children: _cards()
                    .map((w) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: w,
                        ))
                    .toList(),
              )
            : Row(
                children: _cards()
                    .map(
                      (w) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: _cards().last == w ? 0 : 20,
                          ),
                          child: w,
                        ),
                      ),
                    )
                    .toList(),
              );
      },
    );
  }

  List<Widget> _cards() => [
        SummaryCard(
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
        SummaryCard(
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
        SummaryCard(
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
      ];
}

/// Two-column grid: Sales Chart (2/3) + Recent Transactions (1/3).
class _MainGrid extends StatelessWidget {
  const _MainGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Stack vertically on medium/small viewports
        if (c.maxWidth < 800) {
          return const Column(
            children: [
              SalesChartWidget(),
              SizedBox(height: 24),
              RecentTransactionsWidget(),
            ],
          );
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart — 2 parts
            Expanded(
              flex: 2,
              child: SalesChartWidget(),
            ),
            SizedBox(width: 24),
            // Recent sales — 1 part
            Expanded(
              flex: 1,
              child: RecentTransactionsWidget(),
            ),
          ],
        );
      },
    );
  }
}

/// Bottom section: System Status Card + Top Selling Items side by side.
class _BottomSection extends StatelessWidget {
  const _BottomSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 700) {
          return const Column(
            children: [
              SystemStatusCard(),
              SizedBox(height: 24),
              TopSellingCard(),
            ],
          );
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: SystemStatusCard()),
            SizedBox(width: 24),
            Expanded(child: TopSellingCard()),
          ],
        );
      },
    );
  }
}

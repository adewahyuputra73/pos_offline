import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:border_po/state/app_state.dart';
import 'package:border_po/utils/formatters.dart';
import '../components/recent_transactions_widget.dart';
import '../components/sales_chart_widget.dart';
import '../components/sidebar_widget.dart';
import '../components/summary_card.dart';
import '../components/system_status_card.dart';
import '../components/top_bar_widget.dart';
import 'package:border_po/features/dashboard/presentation/components/top_selling_card.dart';
import 'package:border_po/features/dashboard/presentation/components/transactions_management_body.dart';
import '../components/settings_body.dart';
import '../components/checkout_body.dart';
import '../components/ingredient_management_body.dart';
import '../components/hpp_report_body.dart';
import '../components/shift_body.dart';
import '../theme/dashboard_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HomeDashboardPage — main entry for the dashboard.
///
/// LAYOUT:
///   Always renders a sidebar (w=256) + scrollable main content in a Row.
///   On narrow screens the sidebar becomes a Drawer accessed via a hamburger.
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
        final bool isWide = constraints.maxWidth >= 1024; // Use a higher threshold for permanent sidebar
        final bool showPermanentSidebar = isWide; 

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: DC.background,
          resizeToAvoidBottomInset: false,
          drawer: showPermanentSidebar
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
          floatingActionButton: null,
          body: showPermanentSidebar
              ? Row(
                  children: [
                    SidebarWidget(
                      selected: _activeNav,
                      onSelected: (n) => setState(() => _activeNav = n),
                    ),
                    Expanded(child: _buildMainColumn(showPermanentSidebar, constraints.maxWidth)),
                  ],
                )
              : _buildMainColumn(showPermanentSidebar, constraints.maxWidth),
        );
      },
    );
  }

  Widget _buildMainColumn(bool showPermanentSidebar, double maxWidth) {
    return Column(
      children: [
        if (_activeNav != NavItem.settings && _activeNav != NavItem.orders && _activeNav != NavItem.shift)
          TopBarWidget(
            title: _activeNav == NavItem.dashboard
                ? 'Coffee House Dashboard'
                : '',
            leading: showPermanentSidebar
                ? null
                : IconButton(
                    icon: const Icon(Icons.menu_rounded, color: DC.stone900),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
          ),
        Expanded(
          child: _activeNav == NavItem.dashboard
              ? SingleChildScrollView(
                  padding: EdgeInsets.all(maxWidth >= 720 ? 32 : 16),
                  child: const _DashboardBody(),
                )
              : _buildBodyForNav(_activeNav, showPermanentSidebar),
        ),
      ],
    );
  }

  Widget _buildBodyForNav(NavItem nav, bool showPermanentSidebar) {
    switch (nav) {
      case NavItem.dashboard:
        return const _DashboardBody();
      case NavItem.orders:
        return CheckoutBody(
          leading: showPermanentSidebar
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu_rounded, color: DC.stone900),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
        );
      case NavItem.shift:
        return ShiftBody(
          leading: showPermanentSidebar
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu_rounded, color: DC.stone900),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
        );
      case NavItem.transactions:
        return TransactionsManagementBody(
          leading: showPermanentSidebar
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu_rounded, color: DC.stone900),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
        );
      case NavItem.inventory:
        return const IngredientManagementBody();
      case NavItem.hpp:
        return HppReportBody(
          leading: showPermanentSidebar
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu_rounded, color: DC.stone900),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
        );
      case NavItem.settings:
        return SettingsBody(
          leading: showPermanentSidebar
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu_rounded, color: DC.stone900),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
        );
    }
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
        SizedBox(height: 20),
        _LowStockAlert(),
        _MainGridSection(),
        SizedBox(height: 20),
        _BottomSection(),
        SizedBox(height: 48), // FAB clearance
      ],
    );
  }
}

/// Shows a compact warning when any ingredients are low or out of stock.
class _LowStockAlert extends StatelessWidget {
  const _LowStockAlert();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lowStock = state.lowStockIngredients(threshold: 50);
    if (lowStock.isEmpty) return const SizedBox.shrink();

    final outOfStock = lowStock.where((i) => i.stock <= 0).toList();
    final running = lowStock.where((i) => i.stock > 0).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: outOfStock.isNotEmpty
              ? DC.error.withValues(alpha: 0.08)
              : const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: outOfStock.isNotEmpty
                ? DC.error.withValues(alpha: 0.3)
                : const Color(0xFFFFB74D),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: outOfStock.isNotEmpty ? DC.error : const Color(0xFFE65100),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outOfStock.isNotEmpty
                        ? '${outOfStock.length} Bahan Habis!'
                        : '${running.length} Bahan Stok Rendah',
                    style: manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: outOfStock.isNotEmpty ? DC.error : const Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: lowStock.map((ing) {
                      final isOut = ing.stock <= 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOut
                              ? DC.error.withValues(alpha: 0.12)
                              : const Color(0xFFE65100).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOut ? '${ing.name} (HABIS)' : '${ing.name}: ${ing.stock} ${ing.unit}',
                          style: manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOut ? DC.error : const Color(0xFFBF360C),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section 1: 3 bento summary cards — real data from AppState ───────────────

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return LayoutBuilder(
      builder: (ctx, c) {
        final cards = _buildCards(state);
        if (c.maxWidth < 600) {
          return Column(
            children: cards
                .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: w,
                    ))
                .toList(),
          );
        }
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

  List<Widget> _buildCards(AppState state) => [
        _HoverCard(
          child: SummaryCard(
            icon: Icons.payments_outlined,
            iconBg: DC.primaryContainer,
            iconColor: DC.onPrimaryContainer,
            label: "PENDAPATAN KOTOR HARI INI",
            value: formatRupiah(state.todayRevenue),
            subtitle: InfoSubtitle(
              text: 'Termasuk pajak ${formatRupiah(state.todayTax)}',
              icon: Icons.receipt_long_rounded,
            ),
          ),
        ),
        _HoverCard(
          child: SummaryCard(
            icon: Icons.trending_up_rounded,
            iconBg: DC.tertiaryContainer,
            iconColor: DC.onTertiaryContainer,
            label: 'KEUNTUNGAN BERSIH HARI INI',
            value: formatRupiah(state.todayProfit),
            subtitle: InfoSubtitle(
              text: 'Bersih setelah modal & pajak',
              icon: Icons.analytics_outlined,
            ),
          ),
        ),
        _HoverCard(
          child: SummaryCard(
            icon: Icons.receipt_long_outlined,
            iconBg: DC.secondaryContainer,
            iconColor: DC.onSecondaryContainer,
            label: 'TOTAL TRANSAKSI (SEMUA)',
            value: '${state.transactions.length}',
            subtitle: InfoSubtitle(
              text: 'Tersimpan lokal',
              icon: Icons.smartphone_rounded,
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
    final screenHeight = MediaQuery.of(context).size.height;
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
        final chartRowHeight = (screenHeight * 0.55).clamp(300.0, 450.0);
        return SizedBox(
          height: chartRowHeight,
          child: const Row(
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
    final screenHeight = MediaQuery.of(context).size.height;
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
        return const SizedBox(
          height: 240, // Fixed reasonable height for the two cards to fill
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

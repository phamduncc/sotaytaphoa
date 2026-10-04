import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/sale_repository.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/stat_card.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../main.dart' as main_app;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double> _todaySales = {'revenue': 0, 'count': 0};
  Map<String, double> _todayFinance = {'income': 0, 'expense': 0, 'profit': 0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().loadSales();
      context.read<TransactionProvider>().loadAll();
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when SaleProvider or TransactionProvider changes
    _loadData();
  }

  Future<void> _loadData() async {
    final today = DateFormatter.todayDb();
    final salesRepo = SaleRepository();
    final todaySales = await salesRepo.getDailySummary(today);
    final txProvider = context.read<TransactionProvider>();
    final todayFinance = await txProvider.getTodaySummary();
    if (!mounted) return;
    setState(() {
      _todaySales = todaySales;
      _todayFinance = todayFinance;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productProvider = context.watch<ProductProvider>();
    context.watch<SaleProvider>(); // Trigger rebuild on sale changes
    context
        .watch<TransactionProvider>(); // Trigger rebuild on transaction changes
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ProductProvider>().loadAll();
          await _loadData();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dashboardWelcome,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.dashboardGreeting,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                l10n.dashboardTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stat cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      StatCard(
                        title: l10n.dashboardTodayRevenue,
                        value: CurrencyFormatter.formatCompact(
                          _todaySales['revenue'] ?? 0,
                        ),
                        icon: Icons.attach_money_rounded,
                        gradient: AppColors.gradientRevenue,
                      ),
                      StatCard(
                        title: l10n.dashboardTodayProfit,
                        value: CurrencyFormatter.formatCompact(
                          _todayFinance['profit'] ?? 0,
                        ),
                        icon: Icons.trending_up_rounded,
                        gradient: AppColors.gradientProfit,
                      ),
                      StatCard(
                        title: l10n.dashboardTodayInvoices,
                        value: (_todaySales['count'] ?? 0).toInt().toString(),
                        icon: Icons.receipt_long_rounded,
                        gradient: AppColors.gradientInvoice,
                      ),
                      StatCard(
                        title: l10n.dashboardLowStock,
                        value:
                            productProvider.lowStockProducts.length.toString(),
                        icon: Icons.warning_amber_rounded,
                        gradient: AppColors.gradientWarning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Alerts section
                  _buildAlerts(context, l10n, productProvider),
                  const SizedBox(height: 20),

                  // Quick actions
                  _buildQuickActions(context, l10n),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(
    BuildContext context,
    AppLocalizations l10n,
    ProductProvider productProvider,
  ) {
    final theme = Theme.of(context);
    final lowStock = productProvider.lowStockProducts;
    final outOfStock = productProvider.outOfStockProducts;

    if (lowStock.isEmpty && outOfStock.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(l10n.dashboardNoAlerts, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardAlerts,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (outOfStock.isNotEmpty)
          _AlertCard(
            icon: Icons.remove_shopping_cart_rounded,
            color: AppColors.error,
            title: l10n.dashboardOutOfStock,
            count: outOfStock.length,
            items: outOfStock.take(3).map((p) => p.name).toList(),
          ),
        if (outOfStock.isNotEmpty && lowStock.isNotEmpty)
          const SizedBox(height: 8),
        if (lowStock.isNotEmpty)
          _AlertCard(
            icon: Icons.inventory_2_outlined,
            color: AppColors.warning,
            title: l10n.dashboardLowStock,
            count: lowStock.length,
            items:
                lowStock.take(3).map((p) => '${p.name} (${p.stock})').toList(),
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardQuickActions,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: [
            _QuickAction(
              icon: Icons.point_of_sale_rounded,
              label: l10n.navSales,
              color: AppColors.primary,
              onTap: () => _navigateToTab(context, 1),
            ),
            _QuickAction(
              icon: Icons.inventory_2_rounded,
              label: l10n.navProducts,
              color: AppColors.success,
              onTap: () => _navigateToTab(context, 2),
            ),
            _QuickAction(
              icon: Icons.local_shipping_rounded,
              label: l10n.navPurchases,
              color: AppColors.secondary,
              onTap: () => _navigateToFeature(context, 'purchases'),
            ),
            _QuickAction(
              icon: Icons.bar_chart_rounded,
              label: l10n.navReports,
              color: const Color(0xFF6A1B9A),
              onTap: () => _navigateToTab(context, 3),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    final scaffold = main_app.MainScaffoldState.of(context);
    scaffold?.setTab(index);
  }

  void _navigateToFeature(BuildContext context, String feature) {
    Navigator.pushNamed(context, '/$feature');
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final int count;
  final List<String> items;

  const _AlertCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$title ($count)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...items.map(
                    (name) => Text(
                      '• $name',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

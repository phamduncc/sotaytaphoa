import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../providers/product_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 0; // 0=today, 1=week, 2=month
  Map<String, double> _financeSummary = {'income': 0, 'expense': 0, 'profit': 0};
  Map<String, double> _salesSummary = {'revenue': 0, 'count': 0};
  List<Map<String, dynamic>> _bestSelling = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _fromDate {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 1:
        return DateFormatter.getWeekStart(now);
      case 2:
        return DateFormatter.getMonthStart(now);
      default:
        return DateFormatter.todayDb();
    }
  }

  String get _toDate => DateFormatter.todayDb();

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final txRepo = TransactionRepository();
    final saleRepo = SaleRepository();
    final from = _fromDate;
    final to = _toDate;
    final finance = await txRepo.getSummary(fromDate: from, toDate: to);
    final sales = await saleRepo.getPeriodSummary(from, to);
    final best = await saleRepo.getBestSellingProducts(from, to, limit: 5);
    if (mounted) {
      setState(() {
        _financeSummary = finance;
        _salesSummary = sales;
        _bestSelling = best;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productProvider = context.watch<ProductProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: l10n.reportOverview),
            Tab(text: l10n.reportProducts),
          ],
        ),
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _PeriodChip(
                  label: l10n.today,
                  selected: _selectedPeriod == 0,
                  onTap: () {
                    setState(() => _selectedPeriod = 0);
                    _loadData();
                  },
                ),
                const SizedBox(width: 8),
                _PeriodChip(
                  label: l10n.thisWeek,
                  selected: _selectedPeriod == 1,
                  onTap: () {
                    setState(() => _selectedPeriod = 1);
                    _loadData();
                  },
                ),
                const SizedBox(width: 8),
                _PeriodChip(
                  label: l10n.thisMonth,
                  selected: _selectedPeriod == 2,
                  onTap: () {
                    setState(() => _selectedPeriod = 2);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(
                        financeSummary: _financeSummary,
                        salesSummary: _salesSummary,
                        bestSelling: _bestSelling,
                        l10n: l10n,
                        theme: theme,
                      ),
                      _ProductsTab(
                        productProvider: productProvider,
                        l10n: l10n,
                        theme: theme,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Map<String, double> financeSummary;
  final Map<String, double> salesSummary;
  final List<Map<String, dynamic>> bestSelling;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _OverviewTab({
    required this.financeSummary,
    required this.salesSummary,
    required this.bestSelling,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Finance summary
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: l10n.reportRevenue,
                value: CurrencyFormatter.formatCompact(
                    salesSummary['revenue'] ?? 0),
                color: AppColors.primary,
                icon: Icons.attach_money_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                label: l10n.reportProfit,
                value: CurrencyFormatter.formatCompact(
                    financeSummary['profit'] ?? 0),
                color: AppColors.success,
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: l10n.reportExpense,
                value: CurrencyFormatter.formatCompact(
                    financeSummary['expense'] ?? 0),
                color: AppColors.error,
                icon: Icons.trending_down_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                label: l10n.reportInvoicesCount,
                value: (salesSummary['count'] ?? 0).toInt().toString(),
                color: AppColors.secondary,
                icon: Icons.receipt_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Best selling
        if (bestSelling.isNotEmpty) ...[
          Text(l10n.reportBestSelling,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...bestSelling.asMap().entries.map((e) {
            final item = e.value;
            final rank = e.key + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rank <= 3
                        ? AppColors.warning.withOpacity(0.2)
                        : AppColors.primaryContainer,
                    child: Text('$rank',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: rank <= 3
                                ? AppColors.warning
                                : AppColors.primary)),
                  ),
                  title: Text(item['name'] as String? ?? '',
                      style: theme.textTheme.titleSmall),
                  subtitle: Text(
                      '${item['total_qty']} ${item['unit'] ?? ''}'),
                  trailing: Text(
                    CurrencyFormatter.formatCompact(
                        (item['total_revenue'] as num?)?.toDouble() ?? 0),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final ProductProvider productProvider;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _ProductsTab({
    required this.productProvider,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final lowStock = productProvider.lowStockProducts;
    final outOfStock = productProvider.outOfStockProducts;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (outOfStock.isNotEmpty) ...[
          _SectionHeader(
              title: '${l10n.dashboardOutOfStock} (${outOfStock.length})',
              color: AppColors.error),
          const SizedBox(height: 8),
          ...outOfStock.map((p) => _StockCard(product: p, theme: theme)),
          const SizedBox(height: 16),
        ],
        if (lowStock.isNotEmpty) ...[
          _SectionHeader(
              title: '${l10n.reportLowStock} (${lowStock.length})',
              color: AppColors.warning),
          const SizedBox(height: 8),
          ...lowStock.map((p) => _StockCard(product: p, theme: theme)),
        ],
        if (outOfStock.isEmpty && lowStock.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 48),
                  const SizedBox(height: 12),
                  Text(l10n.dashboardNoAlerts,
                      style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ],
    );
  }
}

class _StockCard extends StatelessWidget {
  final dynamic product;
  final ThemeData theme;

  const _StockCard({required this.product, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title: Text(product.name, style: theme.textTheme.titleSmall),
        subtitle: Text(product.categoryName ?? ''),
        trailing: Text(
          '${product.stock} ${product.unit}',
          style: TextStyle(
              color: product.isOutOfStock
                  ? AppColors.error
                  : AppColors.warning,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Theme.of(context).dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: selected ? FontWeight.w600 : null,
              fontSize: 13),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/sale.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/common/empty_state.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SaleProvider>().loadSales());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<SaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invoiceTitle)),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.sales.isEmpty
              ? EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.noData,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.sales.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sale = provider.sales[index];
                    return _InvoiceCard(sale: sale, l10n: l10n);
                  },
                ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Sale sale;
  final AppLocalizations l10n;

  const _InvoiceCard({required this.sale, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HĐ #${sale.id?.toString().padLeft(4, '0')}',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormatter.formatDbDate(sale.date),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatVND(sale.total),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: sale.paymentMethod == 'cash'
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sale.paymentMethod == 'cash'
                          ? l10n.posCash
                          : l10n.posTransfer,
                      style: TextStyle(
                        color: sale.paymentMethod == 'cash'
                            ? AppColors.success
                            : AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<SaleProvider>();
    final sale = await provider.getSaleById(this.sale.id!);
    if (!context.mounted || sale == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => _InvoiceDetail(sale: sale, l10n: l10n),
      ),
    );
  }
}

class _InvoiceDetail extends StatelessWidget {
  final Sale sale;
  final AppLocalizations l10n;

  const _InvoiceDetail({required this.sale, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = sale.items ?? [];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text('HĐ #${sale.id?.toString().padLeft(4, '0')}',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(DateFormatter.formatDbDate(sale.date),
              style: theme.textTheme.bodyMedium),
          const Divider(height: 24),
          Text(l10n.invoiceItems, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                            '${item.productName ?? ''} (x${item.quantity})'),
                      ),
                      Text(CurrencyFormatter.formatVND(item.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total,
                  style: theme.textTheme.titleMedium),
              Text(CurrencyFormatter.formatVND(sale.total),
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

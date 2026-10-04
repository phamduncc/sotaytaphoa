import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/purchase.dart';
import '../../providers/purchase_provider.dart';
import '../../widgets/common/empty_state.dart';
import 'purchase_form_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<PurchaseProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<PurchaseProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.purchaseTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PurchaseFormScreen()));
          if (context.mounted) context.read<PurchaseProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.purchases.isEmpty
              ? EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: l10n.noData,
                  actionLabel: l10n.purchaseAdd,
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PurchaseFormScreen()),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: provider.purchases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = provider.purchases[i];
                    return _PurchaseCard(purchase: p, l10n: l10n);
                  },
                ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;
  final AppLocalizations l10n;

  const _PurchaseCard({required this.purchase, required this.l10n});

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
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_shipping_rounded,
                    color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PO #${purchase.id?.toString().padLeft(4, '0')}',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      purchase.supplierName ?? l10n.productNoSupplier,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.formatDbDate(purchase.date),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.formatVND(purchase.total),
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) async {
    final provider = context.read<PurchaseProvider>();
    final purchase = await provider.getById(this.purchase.id!);
    if (!context.mounted || purchase == null) return;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Padding(
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
              Text('PO #${purchase.id?.toString().padLeft(4, '0')}',
                  style: theme.textTheme.titleLarge),
              Text(purchase.supplierName ?? '',
                  style: theme.textTheme.bodyMedium),
              Text(DateFormatter.formatDbDate(purchase.date),
                  style: theme.textTheme.bodySmall),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  itemCount: purchase.items?.length ?? 0,
                  itemBuilder: (_, i) {
                    final item = purchase.items![i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                  '${item.productName ?? ''} x${item.quantity} ${item.unit ?? ''}')),
                          Text(CurrencyFormatter.formatVND(item.subtotal),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
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
                  Text(l10n.total, style: theme.textTheme.titleMedium),
                  Text(
                    CurrencyFormatter.formatVND(purchase.total),
                    style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

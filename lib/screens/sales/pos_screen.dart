import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/product.dart';
import '../../data/models/sale.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/empty_state.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() => _searchQuery = q);
  }

  void _addToCart(Product p) {
    context.read<SaleProvider>().addToCart(CartItem(
          productId: p.id!,
          productName: p.name,
          price: p.salePrice,
          costPrice: p.costPrice,
          unit: p.unit,
          quantity: 1,
          maxStock: p.stock,
        ));
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saleProvider = context.watch<SaleProvider>();
    final productProvider = context.watch<ProductProvider>();
    final allAvailable =
        productProvider.allProducts.where((p) => !p.isOutOfStock).toList();
    final results = _searchQuery.isEmpty
        ? allAvailable
        : allAvailable.where((p) {
            final q = _searchQuery.toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                (p.barcode?.contains(q) ?? false);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.posTitle),
        actions: [
          if (!saleProvider.cartEmpty)
            TextButton.icon(
              onPressed: () => _showClearDialog(context, l10n, saleProvider),
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white70, size: 18),
              label: Text(l10n.clear,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: l10n.posTitle),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.translate('pos_cart_tab')),
                  if (!saleProvider.cartEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${saleProvider.cartItemCount}',
                          style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProductTab(
            searchCtrl: _searchCtrl,
            results: results,
            onSearch: _onSearch,
            onAdd: _addToCart,
            l10n: l10n,
          ),
          _CartTab(l10n: l10n),
        ],
      ),
    );
  }

  void _showClearDialog(
      BuildContext context, AppLocalizations l10n, SaleProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.posClearCart),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              provider.clearCart();
              Navigator.pop(context);
            },
            child: Text(l10n.clear,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProductTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final List<Product> results;
  final ValueChanged<String> onSearch;
  final ValueChanged<Product> onAdd;
  final AppLocalizations l10n;

  const _ProductTab({
    required this.searchCtrl,
    required this.results,
    required this.onSearch,
    required this.onAdd,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: l10n.posSearchProduct,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchCtrl.clear();
                        onSearch('');
                      },
                    )
                  : null,
            ),
            onChanged: onSearch,
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        searchCtrl.text.isEmpty
                            ? l10n.translate('pos_no_products')
                            : l10n.noResults,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                      ),
                      if (searchCtrl.text.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.translate('pos_add_products_first'),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Switch to Products tab (index 2)
                            final scaffold = context.findAncestorStateOfType<
                                State<StatefulWidget>>();
                            if (scaffold != null &&
                                scaffold.widget.runtimeType.toString() ==
                                    'MainScaffold') {
                              (scaffold as dynamic).setTab(2);
                            }
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.translate('go_to_products')),
                        ),
                      ],
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final p = results[i];
                    return _ProductGridItem(
                        product: p, onAdd: onAdd, l10n: l10n);
                  },
                ),
        ),
      ],
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final Product product;
  final ValueChanged<Product> onAdd;
  final AppLocalizations l10n;

  const _ProductGridItem(
      {required this.product, required this.onAdd, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onAdd(product),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: theme.textTheme.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                CurrencyFormatter.formatVND(product.salePrice),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text('${product.stock} ${product.unit}',
                      style: theme.textTheme.bodySmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartTab extends StatelessWidget {
  final AppLocalizations l10n;
  const _CartTab({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SaleProvider>();
    final theme = Theme.of(context);

    if (provider.cartEmpty) {
      return EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: l10n.posCartEmpty,
        subtitle: l10n.posCartEmptyHint,
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.cart.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = provider.cart[i];
              return Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName,
                                style: theme.textTheme.titleSmall, maxLines: 2),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.formatVND(item.price),
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => provider.updateCartQuantity(
                                item.productId, item.quantity - 1),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.error,
                            iconSize: 22,
                          ),
                          Text('${item.quantity}',
                              style: theme.textTheme.titleSmall),
                          IconButton(
                            onPressed: () => provider.updateCartQuantity(
                                item.productId, item.quantity + 1),
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.primary,
                            iconSize: 22,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          CurrencyFormatter.formatVND(item.subtotal),
                          style: theme.textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.posSubtotal, style: theme.textTheme.titleMedium),
                  Text(
                    CurrencyFormatter.formatVND(provider.cartTotal),
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(context),
                  icon: const Icon(Icons.payment_rounded),
                  label: Text(l10n.posPayment),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _PaymentDialog(l10n: l10n),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final AppLocalizations l10n;
  const _PaymentDialog({required this.l10n});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  String _paymentMethod = 'cash';
  final _customerPayCtrl = TextEditingController();
  double _change = 0;

  @override
  void dispose() {
    _customerPayCtrl.dispose();
    super.dispose();
  }

  void _calcChange(SaleProvider provider) {
    final paid = double.tryParse(_customerPayCtrl.text) ?? 0;
    setState(() => _change = paid - provider.cartTotal);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final provider = context.watch<SaleProvider>();
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.posPayment),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.total, style: theme.textTheme.titleSmall),
                Text(
                  CurrencyFormatter.formatVND(provider.cartTotal),
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(l10n.posPaymentMethod, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MethodChip(
                    label: l10n.posCash,
                    icon: Icons.money_rounded,
                    selected: _paymentMethod == 'cash',
                    onTap: () => setState(() => _paymentMethod = 'cash'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MethodChip(
                    label: l10n.posTransfer,
                    icon: Icons.account_balance_rounded,
                    selected: _paymentMethod == 'transfer',
                    onTap: () => setState(() => _paymentMethod = 'transfer'),
                  ),
                ),
              ],
            ),
            if (_paymentMethod == 'cash') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customerPayCtrl,
                decoration: InputDecoration(labelText: l10n.posCustomerPayment),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calcChange(provider),
              ),
              if (_change >= 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.posChange, style: theme.textTheme.labelLarge),
                    Text(
                      CurrencyFormatter.formatVND(_change),
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: () async {
            final productProvider = context.read<ProductProvider>();
            final transactionProvider = context.read<TransactionProvider>();
            await provider.completeSale(_paymentMethod,
                productProvider: productProvider,
                transactionProvider: transactionProvider);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.posInvoiceCreated),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          child: Text(l10n.posCompleteSale),
        ),
      ],
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: selected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: selected ? AppColors.primary : null,
                    fontWeight: selected ? FontWeight.w600 : null,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

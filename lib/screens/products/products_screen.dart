import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../data/models/product.dart';
import '../../widgets/common/empty_state.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
      context.read<CategoryProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProductProvider>().loadAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (context.mounted) context.read<ProductProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          productProvider.search('');
                        },
                      )
                    : null,
              ),
              onChanged: productProvider.search,
            ),
          ),
          // Category filter chips
          if (categoryProvider.categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: categoryProvider.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(l10n.all),
                        selected: productProvider.selectedCategoryId == null,
                        onSelected: (_) => productProvider.filterByCategory(null),
                      ),
                    );
                  }
                  final cat = categoryProvider.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(cat.name),
                      selected: productProvider.selectedCategoryId == cat.id,
                      onSelected: (_) =>
                          productProvider.filterByCategory(cat.id),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${productProvider.products.length} ${l10n.translate("product_count")}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: productProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: l10n.noData,
                        actionLabel: l10n.productAdd,
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProductFormScreen()),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                        itemCount: productProvider.products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final product = productProvider.products[index];
                          return _ProductCard(product: product);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Color stockColor = AppColors.success;
    String stockLabel = '';
    if (product.isOutOfStock) {
      stockColor = AppColors.error;
      stockLabel = l10n.productOutOfStock;
    } else if (product.isLowStock) {
      stockColor = AppColors.warning;
      stockLabel = l10n.productLowStockWarning;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductFormScreen(product: product)),
          );
          if (context.mounted) context.read<ProductProvider>().loadAll();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          product.categoryName ?? l10n.productNoCategory,
                          style: theme.textTheme.bodySmall,
                        ),
                        if (stockLabel.isNotEmpty) ...[
                          const Text(' · '),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: stockColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(stockLabel,
                                style: TextStyle(
                                    color: stockColor, fontSize: 10)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.formatVND(product.salePrice),
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Icon(Icons.inventory_2_outlined,
                            size: 13,
                            color: stockColor),
                        const SizedBox(width: 3),
                        Text(
                          '${product.stock} ${product.unit}',
                          style: TextStyle(
                              color: stockColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                onSelected: (val) async {
                  if (val == 'edit') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductFormScreen(product: product)),
                    );
                    if (context.mounted)
                      context.read<ProductProvider>().loadAll();
                  } else if (val == 'delete') {
                    _confirmDelete(context, l10n, product);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.edit)
                      ])),
                  PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(l10n.delete,
                            style: const TextStyle(color: AppColors.error))
                      ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppLocalizations l10n, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.productDeleteConfirm),
        content: Text(product.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductProvider>().delete(product.id!);
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

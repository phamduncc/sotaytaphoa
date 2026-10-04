import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/purchase.dart';
import '../../data/models/product.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/transaction_provider.dart';

class PurchaseFormScreen extends StatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _noteCtrl = TextEditingController();
  int? _selectedSupplierId;
  String _date = DateFormatter.todayDb();
  final List<_PurchaseItemEntry> _items = [];

  double get _total => _items.fold(0, (s, i) => s + (i.qty * i.price));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
      context.read<SupplierProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _addItem(Product product) {
    final existing = _items.indexWhere((i) => i.productId == product.id);
    if (existing >= 0) {
      setState(() => _items[existing].qty++);
    } else {
      setState(
        () => _items.add(
          _PurchaseItemEntry(
            productId: product.id!,
            productName: product.name,
            unit: product.unit,
            qty: 1,
            price: product.costPrice,
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).purchaseNoItems)),
      );
      return;
    }
    final purchase = Purchase(
      supplierId: _selectedSupplierId,
      date: _date,
      total: _total,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    final items = _items
        .map(
          (i) => PurchaseItem(
            purchaseId: 0,
            productId: i.productId,
            quantity: i.qty,
            price: i.price,
          ),
        )
        .toList();
    final productProvider = context.read<ProductProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    await context.read<PurchaseProvider>().create(purchase, items,
        productProvider: productProvider,
        transactionProvider: transactionProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).purchaseSaved),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _date = DateFormatter.toDbDate(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suppliers = context.watch<SupplierProvider>().suppliers;
    final products = context.watch<ProductProvider>().allProducts;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.purchaseAdd),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        DropdownButtonFormField<int?>(
                          value: _selectedSupplierId,
                          decoration: InputDecoration(
                            labelText: l10n.purchaseSupplier,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(l10n.productNoSupplier),
                            ),
                            ...suppliers.map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedSupplierId = v),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.purchaseDate,
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                            ),
                            child: Text(DateFormatter.formatDbDate(_date)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _noteCtrl,
                          decoration: InputDecoration(
                            labelText: '${l10n.note} ${l10n.optional}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Product picker
                Text(l10n.purchaseItems, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                DropdownButtonFormField<Product>(
                  key: ValueKey(
                      products.length), // Force rebuild when products change
                  decoration: InputDecoration(
                    labelText: l10n.posSearchProduct,
                    prefixIcon: const Icon(Icons.add_shopping_cart_rounded),
                  ),
                  items: products
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.name} (${p.stock} ${p.unit})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (p) {
                    if (p != null) _addItem(p);
                  },
                  value: null,
                ),
                const SizedBox(height: 16),

                // Items list
                if (_items.isNotEmpty) ...[
                  Text(l10n.purchaseItems, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ..._items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.productName,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      setState(() => _items.removeAt(i)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _NumberField(
                                    label: l10n.quantity,
                                    value: item.qty.toString(),
                                    onChanged: (v) => setState(
                                      () => item.qty = int.tryParse(v) ?? 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _NumberField(
                                    label: l10n.productCostPrice,
                                    value: item.price.toStringAsFixed(0),
                                    onChanged: (v) => setState(
                                      () =>
                                          item.price = double.tryParse(v) ?? 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    CurrencyFormatter.formatCompact(
                                      item.qty * item.price,
                                    ),
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          // Total bar
          if (_items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.cardTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.total, style: theme.textTheme.titleMedium),
                  Text(
                    CurrencyFormatter.formatVND(_total),
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PurchaseItemEntry {
  final int productId;
  final String productName;
  final String unit;
  int qty;
  double price;

  _PurchaseItemEntry({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.qty,
    required this.price,
  });
}

class _NumberField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value);
    ctrl.selection = TextSelection.fromPosition(
      TextPosition(offset: ctrl.text.length),
    );
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}

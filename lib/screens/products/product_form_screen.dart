import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/supplier_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _barcodeCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _saleCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _noteCtrl;
  int? _selectedCategoryId;
  int? _selectedSupplierId;
  String _unit = 'cái';
  String? _expiryDate;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _costCtrl = TextEditingController(text: p?.costPrice.toStringAsFixed(0) ?? '0');
    _saleCtrl = TextEditingController(text: p?.salePrice.toStringAsFixed(0) ?? '0');
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? '0');
    _noteCtrl = TextEditingController(text: p?.note ?? '');
    _selectedCategoryId = p?.categoryId;
    _selectedSupplierId = p?.supplierId;
    _unit = p?.unit ?? 'cái';
    _expiryDate = p?.expiryDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadAll();
      context.read<SupplierProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _barcodeCtrl.dispose();
    _costCtrl.dispose();
    _saleCtrl.dispose();
    _stockCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final product = Product(
      id: widget.product?.id,
      name: _nameCtrl.text.trim(),
      barcode: _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
      categoryId: _selectedCategoryId,
      costPrice: double.tryParse(_costCtrl.text) ?? 0,
      salePrice: double.tryParse(_saleCtrl.text) ?? 0,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      unit: _unit,
      expiryDate: _expiryDate,
      supplierId: _selectedSupplierId,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    final provider = context.read<ProductProvider>();
    if (_isEdit) {
      await provider.update(product);
    } else {
      await provider.add(product);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).productSaved)),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cats = context.watch<CategoryProvider>().categories;
    final suppliers = context.watch<SupplierProvider>().suppliers;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.productEdit : l10n.productAdd),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(l10n.productName, [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.productName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _barcodeCtrl,
                decoration: InputDecoration(
                  labelText: '${l10n.productBarcode} ${l10n.optional}',
                  suffixIcon: const Icon(Icons.qr_code_scanner_rounded),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(l10n.productCategory, [
              DropdownButtonFormField<int?>(
                value: _selectedCategoryId,
                decoration: InputDecoration(labelText: l10n.productCategory),
                items: [
                  DropdownMenuItem(
                      value: null, child: Text(l10n.productNoCategory)),
                  ...cats.map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _selectedSupplierId,
                decoration: InputDecoration(labelText: l10n.productSupplier),
                items: [
                  DropdownMenuItem(
                      value: null, child: Text(l10n.productNoSupplier)),
                  ...suppliers.map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name))),
                ],
                onChanged: (v) => setState(() => _selectedSupplierId = v),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(l10n.price, [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costCtrl,
                      decoration: InputDecoration(labelText: l10n.productCostPrice),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _saleCtrl,
                      decoration: InputDecoration(labelText: l10n.productSalePrice),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(l10n.productStock, [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: InputDecoration(labelText: l10n.productStock),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      decoration: InputDecoration(labelText: l10n.productUnit),
                      items: AppConstants.productUnits
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => _unit = v ?? 'cái'),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(l10n.productExpiryDate, [
              InkWell(
                onTap: _pickExpiryDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText:
                        '${l10n.productExpiryDate} ${l10n.optional}',
                    suffixIcon: _expiryDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _expiryDate = null),
                          )
                        : const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    _expiryDate != null
                        ? _expiryDate!.replaceAll('-', '/')
                        : l10n.selectDate,
                    style: _expiryDate != null
                        ? null
                        : TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(l10n.note, [
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                    labelText: '${l10n.note} ${l10n.optional}'),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(_isEdit ? l10n.save : l10n.productAdd,
                  style: const TextStyle(fontSize: 16)),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _confirmDelete(context, l10n),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.delete),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.productDeleteConfirm),
        content: Text(widget.product!.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductProvider>().delete(widget.product!.id!);
              Navigator.pop(context);
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

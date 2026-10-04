import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/supplier.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/common/empty_state.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SupplierProvider>().loadAll());
  }

  void _showForm(BuildContext context, AppLocalizations l10n,
      {Supplier? supplier}) {
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final noteCtrl = TextEditingController(text: supplier?.note ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  supplier == null
                      ? l10n.supplierAdd
                      : l10n.supplierEdit,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.supplierName),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(labelText: l10n.supplierPhone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressCtrl,
                decoration: InputDecoration(labelText: l10n.supplierAddress),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: l10n.supplierEmail),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                    labelText: '${l10n.supplierNote} ${l10n.optional}'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final s = Supplier(
                          id: supplier?.id,
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim().isEmpty
                              ? null
                              : phoneCtrl.text.trim(),
                          address: addressCtrl.text.trim().isEmpty
                              ? null
                              : addressCtrl.text.trim(),
                          email: emailCtrl.text.trim().isEmpty
                              ? null
                              : emailCtrl.text.trim(),
                          note: noteCtrl.text.trim().isEmpty
                              ? null
                              : noteCtrl.text.trim(),
                        );
                        final provider = context.read<SupplierProvider>();
                        if (supplier == null) {
                          await provider.add(s);
                        } else {
                          await provider.update(s);
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<SupplierProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supplierTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, l10n),
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.suppliers.isEmpty
              ? EmptyState(
                  icon: Icons.people_outline,
                  title: l10n.noData,
                  actionLabel: l10n.supplierAdd,
                  onAction: () => _showForm(context, l10n),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: provider.suppliers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = provider.suppliers[index];
                    return _SupplierCard(
                      supplier: s,
                      l10n: l10n,
                      onEdit: () =>
                          _showForm(context, l10n, supplier: s),
                      onDelete: () => _confirmDelete(context, l10n, s),
                    );
                  },
                ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppLocalizations l10n, Supplier supplier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.supplierDeleteConfirm),
        content: Text(supplier.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SupplierProvider>().delete(supplier.id!);
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final AppLocalizations l10n;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.l10n,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.store_rounded,
                  color: AppColors.secondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(supplier.name, style: theme.textTheme.titleSmall),
                  if (supplier.phone != null) ...[
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.phone_outlined,
                          size: 13, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(supplier.phone!,
                          style: theme.textTheme.bodySmall),
                    ]),
                  ],
                  if (supplier.address != null) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(supplier.address!,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
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
                          style:
                              const TextStyle(color: AppColors.error))
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

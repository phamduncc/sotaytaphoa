import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/empty_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CategoryProvider>().loadAll());
  }

  void _showForm(BuildContext context, AppLocalizations l10n,
      {Category? category}) {
    final ctrl = TextEditingController(text: category?.name ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category == null ? l10n.categoryAdd : l10n.categoryEdit,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.categoryName),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (ctrl.text.trim().isEmpty) return;
                      final provider = context.read<CategoryProvider>();
                      if (category == null) {
                        await provider
                            .add(Category(name: ctrl.text.trim()));
                      } else {
                        await provider.update(
                            category.copyWith(name: ctrl.text.trim()));
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoryTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, l10n),
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.categories.isEmpty
              ? EmptyState(
                  icon: Icons.category_outlined,
                  title: l10n.noData,
                  actionLabel: l10n.categoryAdd,
                  onAction: () => _showForm(context, l10n),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: provider.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cat = provider.categories[index];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.category_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        title: Text(cat.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () =>
                                  _showForm(context, l10n, category: cat),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  size: 20, color: AppColors.error),
                              onPressed: () =>
                                  _confirmDelete(context, l10n, cat),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppLocalizations l10n, Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.categoryDeleteConfirm),
        content: Text(category.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CategoryProvider>().delete(category.id!);
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

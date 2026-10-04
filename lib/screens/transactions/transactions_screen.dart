import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/app_transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/empty_state.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<TransactionProvider>().loadAll());
  }

  void _showForm(BuildContext context, AppLocalizations l10n,
      {AppTransaction? tx}) {
    final descCtrl = TextEditingController(text: tx?.description ?? '');
    final amtCtrl =
        TextEditingController(text: tx?.amount.toStringAsFixed(0) ?? '');
    String type = tx?.type ?? 'income';
    String date = tx?.date ?? DateFormatter.nowDb();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tx == null ? l10n.transactionAdd : l10n.edit,
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TypeChip(
                      label: l10n.transactionIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.success,
                      selected: type == 'income',
                      onTap: () => setModalState(() => type = 'income'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TypeChip(
                      label: l10n.transactionExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.error,
                      selected: type == 'expense',
                      onTap: () => setModalState(() => type = 'expense'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amtCtrl,
                decoration: InputDecoration(labelText: l10n.amount),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration:
                    InputDecoration(labelText: l10n.transactionDescription),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amt = double.tryParse(amtCtrl.text) ?? 0;
                    if (amt <= 0 || descCtrl.text.trim().isEmpty) return;
                    final newTx = AppTransaction(
                      id: tx?.id,
                      type: type,
                      amount: amt,
                      date: date,
                      description: descCtrl.text.trim(),
                    );
                    final provider = context.read<TransactionProvider>();
                    if (tx == null) {
                      await provider.add(newTx);
                    } else {
                      await provider.update(newTx);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, l10n),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: l10n.transactionTotalIncome,
                    value:
                        CurrencyFormatter.formatCompact(provider.totalIncome),
                    color: AppColors.success,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: l10n.transactionTotalExpense,
                    value:
                        CurrencyFormatter.formatCompact(provider.totalExpense),
                    color: AppColors.error,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: l10n.transactionProfit,
                    value: CurrencyFormatter.formatCompact(provider.profit),
                    color: provider.profit >= 0
                        ? AppColors.primary
                        : AppColors.error,
                    icon: Icons.account_balance_rounded,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : provider.transactions.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.noData,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                        itemCount: provider.transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, i) {
                          final tx = provider.transactions[i];
                          return _TxCard(
                            tx: tx,
                            l10n: l10n,
                            onEdit: () => _showForm(context, l10n, tx: tx),
                            onDelete: () => _confirmDelete(context, l10n, tx),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppLocalizations l10n, AppTransaction tx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.transactionDeleteConfirm),
        content: Text(tx.description),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TransactionProvider>().delete(tx.id!);
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  final AppTransaction tx;
  final AppLocalizations l10n;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TxCard(
      {required this.tx,
      required this.l10n,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = tx.isIncome;
    final color = isIncome ? AppColors.success : AppColors.error;

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: color,
            size: 20,
          ),
        ),
        title: Text(tx.description,
            style: theme.textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(DateFormatter.formatDbDate(tx.date),
            style: theme.textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (isIncome ? '+' : '-') + CurrencyFormatter.formatVND(tx.amount),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 14),
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
                          style: const TextStyle(color: AppColors.error))
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? color : Theme.of(context).dividerColor,
              width: selected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

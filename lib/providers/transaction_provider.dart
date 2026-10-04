import 'package:flutter/material.dart';
import '../data/models/app_transaction.dart';
import '../data/repositories/transaction_repository.dart';
import '../core/utils/date_formatter.dart';

class TransactionProvider extends ChangeNotifier {
  final _repo = TransactionRepository();

  List<AppTransaction> _transactions = [];
  Map<String, double> _summary = {'income': 0, 'expense': 0, 'profit': 0};
  bool _loading = false;

  List<AppTransaction> get transactions => _transactions;
  Map<String, double> get summary => _summary;
  bool get loading => _loading;
  double get totalIncome => _summary['income'] ?? 0;
  double get totalExpense => _summary['expense'] ?? 0;
  double get profit => _summary['profit'] ?? 0;

  Future<void> loadAll({String? fromDate, String? toDate}) async {
    _loading = true;
    notifyListeners();
    _transactions =
        await _repo.getAll(fromDate: fromDate, toDate: toDate);
    _summary = await _repo.getSummary(fromDate: fromDate, toDate: toDate);
    _loading = false;
    notifyListeners();
  }

  Future<void> add(AppTransaction tx) async {
    await _repo.insert(tx);
    await loadAll();
  }

  Future<void> update(AppTransaction tx) async {
    await _repo.update(tx);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<Map<String, double>> getTodaySummary() {
    final today = DateFormatter.todayDb();
    return _repo.getSummary(fromDate: today, toDate: today);
  }

  Future<Map<String, double>> getMonthSummary() {
    final now = DateTime.now();
    return _repo.getSummary(
      fromDate: DateFormatter.getMonthStart(now),
      toDate: DateFormatter.getMonthEnd(now),
    );
  }
}

import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/app_transaction.dart';

class TransactionRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<AppTransaction>> getAll(
      {String? fromDate, String? toDate}) async {
    final db = await _db;
    String where = '';
    List<dynamic> args = [];
    if (fromDate != null && toDate != null) {
      where = 'WHERE date BETWEEN ? AND ?';
      args = [fromDate, '$toDate 23:59:59'];
    }
    final maps = await db.rawQuery(
        'SELECT * FROM transactions $where ORDER BY date DESC', args);
    return maps.map(AppTransaction.fromMap).toList();
  }

  Future<int> insert(AppTransaction tx) async {
    final db = await _db;
    return db.insert('transactions', tx.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(AppTransaction tx) async {
    final db = await _db;
    return db.update('transactions', tx.toMap(),
        where: 'id = ?', whereArgs: [tx.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getSummary(
      {String? fromDate, String? toDate}) async {
    final db = await _db;
    String where = '';
    List<dynamic> args = [];
    if (fromDate != null && toDate != null) {
      where = 'WHERE date BETWEEN ? AND ?';
      args = [fromDate, '$toDate 23:59:59'];
    }
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE WHEN type='income' THEN amount ELSE 0 END), 0) as total_income,
        COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END), 0) as total_expense
      FROM transactions $where
    ''', args);
    final row = result.first;
    final income = (row['total_income'] as num?)?.toDouble() ?? 0;
    final expense = (row['total_expense'] as num?)?.toDouble() ?? 0;
    return {
      'income': income,
      'expense': expense,
      'profit': income - expense,
    };
  }
}

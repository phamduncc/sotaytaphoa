import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/sale.dart';

class SaleRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<Sale>> getAll({String? fromDate, String? toDate}) async {
    final db = await _db;
    String where = '';
    List<dynamic> args = [];
    if (fromDate != null && toDate != null) {
      where = 'WHERE date BETWEEN ? AND ?';
      args = [fromDate, '$toDate 23:59:59'];
    } else if (fromDate != null) {
      where = 'WHERE date >= ?';
      args = [fromDate];
    }
    final maps = await db.rawQuery(
        'SELECT * FROM sales $where ORDER BY date DESC', args);
    return maps.map(Sale.fromMap).toList();
  }

  Future<Sale?> getById(int id) async {
    final db = await _db;
    final maps =
        await db.query('sales', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final sale = Sale.fromMap(maps.first);
    final items = await getItemsBySaleId(id);
    return sale.copyWith(items: items);
  }

  Future<List<SaleItem>> getItemsBySaleId(int saleId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT si.*, p.name as product_name, p.unit
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      WHERE si.sale_id = ?
    ''', [saleId]);
    return maps.map(SaleItem.fromMap).toList();
  }

  Future<int> insert(Sale sale) async {
    final db = await _db;
    return db.insert('sales', sale.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertItems(List<SaleItem> items) async {
    final db = await _db;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('sale_items', item.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> delete(int id) async {
    final db = await _db;
    await db.delete('sale_items', where: 'sale_id = ?', whereArgs: [id]);
    return db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getDailySummary(String date) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(s.total), 0) as revenue,
        COUNT(s.id) as count
      FROM sales s
      WHERE date(s.date) = ?
    ''', [date]);
    final row = result.first;
    return {
      'revenue': (row['revenue'] as num?)?.toDouble() ?? 0,
      'count': (row['count'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<Map<String, double>> getPeriodSummary(
      String fromDate, String toDate) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(s.total), 0) as revenue,
        COUNT(s.id) as count
      FROM sales s
      WHERE date(s.date) BETWEEN ? AND ?
    ''', [fromDate, toDate]);
    final row = result.first;
    return {
      'revenue': (row['revenue'] as num?)?.toDouble() ?? 0,
      'count': (row['count'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getBestSellingProducts(
      String fromDate, String toDate,
      {int limit = 10}) async {
    final db = await _db;
    return db.rawQuery('''
      SELECT p.name, p.unit, SUM(si.quantity) as total_qty, 
             SUM(si.quantity * si.price) as total_revenue
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      JOIN sales s ON si.sale_id = s.id
      WHERE date(s.date) BETWEEN ? AND ?
      GROUP BY si.product_id
      ORDER BY total_qty DESC
      LIMIT ?
    ''', [fromDate, toDate, limit]);
  }

  Future<List<Map<String, dynamic>>> getDailyRevenueChart(
      String fromDate, String toDate) async {
    final db = await _db;
    return db.rawQuery('''
      SELECT date(date) as day, COALESCE(SUM(total), 0) as revenue
      FROM sales
      WHERE date(date) BETWEEN ? AND ?
      GROUP BY date(date)
      ORDER BY day ASC
    ''', [fromDate, toDate]);
  }
}

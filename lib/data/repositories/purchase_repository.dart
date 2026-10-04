import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/purchase.dart';

class PurchaseRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<Purchase>> getAll() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, s.name as supplier_name
      FROM purchases p
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      ORDER BY p.date DESC
    ''');
    return maps.map(Purchase.fromMap).toList();
  }

  Future<Purchase?> getById(int id) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, s.name as supplier_name
      FROM purchases p
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    final purchase = Purchase.fromMap(maps.first);
    final items = await getItemsByPurchaseId(id);
    return purchase.copyWith(items: items);
  }

  Future<List<PurchaseItem>> getItemsByPurchaseId(int purchaseId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT pi.*, p.name as product_name, p.unit
      FROM purchase_items pi
      JOIN products p ON pi.product_id = p.id
      WHERE pi.purchase_id = ?
    ''', [purchaseId]);
    return maps.map(PurchaseItem.fromMap).toList();
  }

  Future<int> insert(Purchase purchase) async {
    final db = await _db;
    return db.insert('purchases', purchase.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertItems(List<PurchaseItem> items) async {
    final db = await _db;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('purchase_items', item.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> delete(int id) async {
    final db = await _db;
    await db.delete('purchase_items',
        where: 'purchase_id = ?', whereArgs: [id]);
    return db.delete('purchases', where: 'id = ?', whereArgs: [id]);
  }
}

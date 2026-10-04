import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/supplier.dart';

class SupplierRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<Supplier>> getAll() async {
    final db = await _db;
    final maps = await db.query('suppliers', orderBy: 'name ASC');
    return maps.map(Supplier.fromMap).toList();
  }

  Future<Supplier?> getById(int id) async {
    final db = await _db;
    final maps =
        await db.query('suppliers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Supplier.fromMap(maps.first);
  }

  Future<int> insert(Supplier supplier) async {
    final db = await _db;
    return db.insert('suppliers', supplier.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Supplier supplier) async {
    final db = await _db;
    return db.update('suppliers', supplier.toMap(),
        where: 'id = ?', whereArgs: [supplier.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getProductCount(int supplierId) async {
    final db = await _db;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM products WHERE supplier_id = ?',
        [supplierId]);
    return (result.first['count'] as int?) ?? 0;
  }
}

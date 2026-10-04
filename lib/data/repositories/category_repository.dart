import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/category.dart';

class CategoryRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<Category>> getAll() async {
    final db = await _db;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map(Category.fromMap).toList();
  }

  Future<Category?> getById(int id) async {
    final db = await _db;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<int> insert(Category category) async {
    final db = await _db;
    return db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Category category) async {
    final db = await _db;
    return db.update('categories', category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getProductCount(int categoryId) async {
    final db = await _db;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM products WHERE category_id = ?',
        [categoryId]);
    return (result.first['count'] as int?) ?? 0;
  }
}

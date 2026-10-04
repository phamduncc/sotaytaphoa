import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<List<Product>> getAll() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      ORDER BY p.name ASC
    ''');
    return maps.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<List<Product>> search(String query) async {
    final db = await _db;
    final q = '%$query%';
    final maps = await db.rawQuery('''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.name LIKE ? OR p.barcode LIKE ?
      ORDER BY p.name ASC
    ''', [q, q]);
    return maps.map(Product.fromMap).toList();
  }

  Future<List<Product>> getByCategory(int categoryId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.category_id = ?
      ORDER BY p.name ASC
    ''', [categoryId]);
    return maps.map(Product.fromMap).toList();
  }

  Future<List<Product>> getLowStock(int threshold) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.stock <= ? AND p.stock > 0
      ORDER BY p.stock ASC
    ''', [threshold]);
    return maps.map(Product.fromMap).toList();
  }

  Future<List<Product>> getOutOfStock() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.stock <= 0
      ORDER BY p.name ASC
    ''');
    return maps.map(Product.fromMap).toList();
  }

  Future<Product?> getByBarcode(String barcode) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name as category_name, s.name as supplier_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.barcode = ?
    ''', [barcode]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> insert(Product product) async {
    final db = await _db;
    return db.insert('products', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Product product) async {
    final db = await _db;
    return db.update('products', product.toMap(),
        where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStock(int productId, int delta) async {
    final db = await _db;
    await db.rawUpdate(
        'UPDATE products SET stock = stock + ? WHERE id = ?',
        [delta, productId]);
  }

  Future<int> getTotalCount() async {
    final db = await _db;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return (result.first['count'] as int?) ?? 0;
  }
}

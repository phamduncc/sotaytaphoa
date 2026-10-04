import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final _repo = ProductRepository();

  List<Product> _products = [];
  List<Product> _filtered = [];
  bool _loading = false;
  String _searchQuery = '';
  int? _selectedCategoryId;
  int _lowStockThreshold = AppConstants.defaultLowStockThreshold;

  List<Product> get products => _filtered;
  List<Product> get allProducts => _products;
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  int get lowStockThreshold => _lowStockThreshold;

  List<Product> get lowStockProducts =>
      _products.where((p) => p.stock > 0 && p.stock <= _lowStockThreshold).toList();
  List<Product> get outOfStockProducts =>
      _products.where((p) => p.isOutOfStock).toList();

  Future<void> loadThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    _lowStockThreshold =
        prefs.getInt(AppConstants.keyLowStockThreshold) ?? AppConstants.defaultLowStockThreshold;
  }

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    await loadThreshold();
    _products = await _repo.getAll();
    _applyFilter();
    _loading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var list = _products;
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.barcode?.contains(q) ?? false))
          .toList();
    }
    _filtered = list;
  }

  Future<Product?> getByBarcode(String barcode) => _repo.getByBarcode(barcode);

  Future<void> add(Product product) async {
    await _repo.insert(product);
    await loadAll();
  }

  Future<void> update(Product product) async {
    await _repo.update(product);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<int> getTotalCount() => _repo.getTotalCount();
}

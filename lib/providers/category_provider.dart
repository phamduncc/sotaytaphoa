import 'package:flutter/material.dart';
import '../data/models/category.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final _repo = CategoryRepository();

  List<Category> _categories = [];
  bool _loading = false;

  List<Category> get categories => _categories;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _categories = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Category category) async {
    await _repo.insert(category);
    await loadAll();
  }

  Future<void> update(Category category) async {
    await _repo.update(category);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<int> getProductCount(int categoryId) =>
      _repo.getProductCount(categoryId);
}

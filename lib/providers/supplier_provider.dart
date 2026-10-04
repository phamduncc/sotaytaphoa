import 'package:flutter/material.dart';
import '../data/models/supplier.dart';
import '../data/repositories/supplier_repository.dart';

class SupplierProvider extends ChangeNotifier {
  final _repo = SupplierRepository();

  List<Supplier> _suppliers = [];
  bool _loading = false;

  List<Supplier> get suppliers => _suppliers;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _suppliers = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Supplier supplier) async {
    await _repo.insert(supplier);
    await loadAll();
  }

  Future<void> update(Supplier supplier) async {
    await _repo.update(supplier);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<int> getProductCount(int supplierId) =>
      _repo.getProductCount(supplierId);
}

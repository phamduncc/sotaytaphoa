import 'package:flutter/material.dart';
import '../data/models/purchase.dart';
import '../data/repositories/purchase_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/models/app_transaction.dart';
import '../core/utils/date_formatter.dart';
import 'product_provider.dart';
import 'transaction_provider.dart';

class PurchaseProvider extends ChangeNotifier {
  final _purchaseRepo = PurchaseRepository();
  final _productRepo = ProductRepository();
  final _txRepo = TransactionRepository();

  List<Purchase> _purchases = [];
  bool _loading = false;

  List<Purchase> get purchases => _purchases;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _purchases = await _purchaseRepo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<Purchase?> getById(int id) => _purchaseRepo.getById(id);

  Future<void> create(Purchase purchase, List<PurchaseItem> items,
      {ProductProvider? productProvider,
      TransactionProvider? transactionProvider}) async {
    final purchaseId = await _purchaseRepo.insert(purchase);
    final updatedItems = items
        .map((i) => PurchaseItem(
              purchaseId: purchaseId,
              productId: i.productId,
              quantity: i.quantity,
              price: i.price,
              productName: i.productName,
              unit: i.unit,
            ))
        .toList();
    await _purchaseRepo.insertItems(updatedItems);

    for (final item in items) {
      await _productRepo.updateStock(item.productId, item.quantity);
    }
    await productProvider?.loadAll();

    await _txRepo.insert(AppTransaction(
      type: 'expense',
      amount: purchase.total,
      date: DateFormatter.nowDb(),
      description: 'Nhập hàng - PO #${purchaseId.toString().padLeft(4, '0')}',
    ));
    await transactionProvider?.loadAll();

    await loadAll();
  }

  Future<void> delete(int id) async {
    await _purchaseRepo.delete(id);
    await loadAll();
  }
}

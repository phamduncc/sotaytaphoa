import 'package:flutter/material.dart';
import '../data/models/sale.dart';
import '../data/repositories/sale_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/models/app_transaction.dart';
import '../core/utils/date_formatter.dart';
import 'product_provider.dart';
import 'transaction_provider.dart';

class SaleProvider extends ChangeNotifier {
  final _saleRepo = SaleRepository();
  final _productRepo = ProductRepository();
  final _txRepo = TransactionRepository();

  List<Sale> _sales = [];
  List<CartItem> _cart = [];
  bool _loading = false;

  List<Sale> get sales => _sales;
  List<CartItem> get cart => _cart;
  bool get loading => _loading;
  bool get cartEmpty => _cart.isEmpty;
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  double get cartProfit => _cart.fold(0, (sum, item) => sum + item.profit);

  Future<void> loadSales({String? fromDate, String? toDate}) async {
    _loading = true;
    notifyListeners();
    _sales = await _saleRepo.getAll(fromDate: fromDate, toDate: toDate);
    _loading = false;
    notifyListeners();
  }

  Future<Sale?> getSaleById(int id) => _saleRepo.getById(id);

  void addToCart(CartItem item) {
    final idx = _cart.indexWhere((c) => c.productId == item.productId);
    if (idx >= 0) {
      final existing = _cart[idx];
      if (existing.quantity < existing.maxStock) {
        _cart[idx].quantity++;
      }
    } else {
      _cart.add(item);
    }
    notifyListeners();
  }

  void updateCartQuantity(int productId, int quantity) {
    final idx = _cart.indexWhere((c) => c.productId == productId);
    if (idx >= 0) {
      if (quantity <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx].quantity = quantity.clamp(1, _cart[idx].maxStock);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _cart.removeWhere((c) => c.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<int> completeSale(String paymentMethod,
      {String? note,
      ProductProvider? productProvider,
      TransactionProvider? transactionProvider}) async {
    final now = DateFormatter.nowDb();
    final sale = Sale(
      date: now,
      total: cartTotal,
      paymentMethod: paymentMethod,
      note: note,
    );
    final saleId = await _saleRepo.insert(sale);

    final items = _cart
        .map((c) => SaleItem(
              saleId: saleId,
              productId: c.productId,
              quantity: c.quantity,
              price: c.price,
            ))
        .toList();
    await _saleRepo.insertItems(items);

    // Update stock
    for (final item in _cart) {
      await _productRepo.updateStock(item.productId, -item.quantity);
    }
    await productProvider?.loadAll();

    // Record transaction
    await _txRepo.insert(AppTransaction(
      type: 'income',
      amount: cartTotal,
      date: now,
      description: 'Bán hàng - HĐ #${saleId.toString().padLeft(4, '0')}',
    ));
    await transactionProvider?.loadAll();
    await loadSales();

    clearCart();
    return saleId;
  }

  Future<void> deleteSale(int id) async {
    await _saleRepo.delete(id);
    await loadSales();
  }
}

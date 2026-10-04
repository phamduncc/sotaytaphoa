class Sale {
  final int? id;
  final String date;
  final double total;
  final String paymentMethod;
  final String? note;
  final List<SaleItem>? items;

  const Sale({
    this.id,
    required this.date,
    required this.total,
    this.paymentMethod = 'cash',
    this.note,
    this.items,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'total': total,
        'payment_method': paymentMethod,
        'note': note,
      };

  factory Sale.fromMap(Map<String, dynamic> map) => Sale(
        id: map['id'] as int?,
        date: map['date'] as String,
        total: (map['total'] as num?)?.toDouble() ?? 0,
        paymentMethod: (map['payment_method'] as String?) ?? 'cash',
        note: map['note'] as String?,
      );

  Sale copyWith({
    int? id,
    String? date,
    double? total,
    String? paymentMethod,
    String? note,
    List<SaleItem>? items,
  }) =>
      Sale(
        id: id ?? this.id,
        date: date ?? this.date,
        total: total ?? this.total,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        note: note ?? this.note,
        items: items ?? this.items,
      );
}

class SaleItem {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double price;
  // Joined
  final String? productName;
  final String? unit;

  const SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
    this.unit,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'sale_id': saleId,
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      };

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
        id: map['id'] as int?,
        saleId: map['sale_id'] as int,
        productId: map['product_id'] as int,
        quantity: map['quantity'] as int,
        price: (map['price'] as num?)?.toDouble() ?? 0,
        productName: map['product_name'] as String?,
        unit: map['unit'] as String?,
      );
}

class CartItem {
  final int productId;
  final String productName;
  final double price;
  final double costPrice;
  final String unit;
  int quantity;
  final int maxStock;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.costPrice,
    required this.unit,
    required this.quantity,
    required this.maxStock,
  });

  double get subtotal => price * quantity;
  double get profit => (price - costPrice) * quantity;
}

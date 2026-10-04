class Purchase {
  final int? id;
  final int? supplierId;
  final String date;
  final double total;
  final String? note;
  // Joined
  final String? supplierName;
  final List<PurchaseItem>? items;

  const Purchase({
    this.id,
    this.supplierId,
    required this.date,
    required this.total,
    this.note,
    this.supplierName,
    this.items,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'supplier_id': supplierId,
        'date': date,
        'total': total,
        'note': note,
      };

  factory Purchase.fromMap(Map<String, dynamic> map) => Purchase(
        id: map['id'] as int?,
        supplierId: map['supplier_id'] as int?,
        date: map['date'] as String,
        total: (map['total'] as num?)?.toDouble() ?? 0,
        note: map['note'] as String?,
        supplierName: map['supplier_name'] as String?,
      );

  Purchase copyWith({
    int? id,
    int? supplierId,
    String? date,
    double? total,
    String? note,
    String? supplierName,
    List<PurchaseItem>? items,
  }) =>
      Purchase(
        id: id ?? this.id,
        supplierId: supplierId ?? this.supplierId,
        date: date ?? this.date,
        total: total ?? this.total,
        note: note ?? this.note,
        supplierName: supplierName ?? this.supplierName,
        items: items ?? this.items,
      );
}

class PurchaseItem {
  final int? id;
  final int purchaseId;
  final int productId;
  final int quantity;
  final double price;
  // Joined
  final String? productName;
  final String? unit;

  const PurchaseItem({
    this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
    this.unit,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'purchase_id': purchaseId,
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      };

  factory PurchaseItem.fromMap(Map<String, dynamic> map) => PurchaseItem(
        id: map['id'] as int?,
        purchaseId: map['purchase_id'] as int,
        productId: map['product_id'] as int,
        quantity: map['quantity'] as int,
        price: (map['price'] as num?)?.toDouble() ?? 0,
        productName: map['product_name'] as String?,
        unit: map['unit'] as String?,
      );
}

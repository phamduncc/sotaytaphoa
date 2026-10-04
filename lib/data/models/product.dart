class Product {
  final int? id;
  final String name;
  final String? barcode;
  final int? categoryId;
  final double costPrice;
  final double salePrice;
  final int stock;
  final String unit;
  final String? expiryDate;
  final int? supplierId;
  final String? note;
  // Joined fields
  final String? categoryName;
  final String? supplierName;

  const Product({
    this.id,
    required this.name,
    this.barcode,
    this.categoryId,
    required this.costPrice,
    required this.salePrice,
    required this.stock,
    this.unit = 'cái',
    this.expiryDate,
    this.supplierId,
    this.note,
    this.categoryName,
    this.supplierName,
  });

  double get profitMargin => salePrice > 0 ? ((salePrice - costPrice) / salePrice) * 100 : 0;
  double get profit => salePrice - costPrice;
  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= 5;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'barcode': barcode,
        'category_id': categoryId,
        'cost_price': costPrice,
        'sale_price': salePrice,
        'stock': stock,
        'unit': unit,
        'expiry_date': expiryDate,
        'supplier_id': supplierId,
        'note': note,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as int?,
        name: map['name'] as String,
        barcode: map['barcode'] as String?,
        categoryId: map['category_id'] as int?,
        costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
        salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0,
        stock: (map['stock'] as int?) ?? 0,
        unit: (map['unit'] as String?) ?? 'cái',
        expiryDate: map['expiry_date'] as String?,
        supplierId: map['supplier_id'] as int?,
        note: map['note'] as String?,
        categoryName: map['category_name'] as String?,
        supplierName: map['supplier_name'] as String?,
      );

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    int? categoryId,
    double? costPrice,
    double? salePrice,
    int? stock,
    String? unit,
    String? expiryDate,
    int? supplierId,
    String? note,
    String? categoryName,
    String? supplierName,
  }) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        barcode: barcode ?? this.barcode,
        categoryId: categoryId ?? this.categoryId,
        costPrice: costPrice ?? this.costPrice,
        salePrice: salePrice ?? this.salePrice,
        stock: stock ?? this.stock,
        unit: unit ?? this.unit,
        expiryDate: expiryDate ?? this.expiryDate,
        supplierId: supplierId ?? this.supplierId,
        note: note ?? this.note,
        categoryName: categoryName ?? this.categoryName,
        supplierName: supplierName ?? this.supplierName,
      );
}

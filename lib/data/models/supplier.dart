class Supplier {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? email;
  final String? note;

  const Supplier({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.email,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'email': email,
        'note': note,
      };

  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: map['phone'] as String?,
        address: map['address'] as String?,
        email: map['email'] as String?,
        note: map['note'] as String?,
      );

  Supplier copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    String? note,
  }) =>
      Supplier(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        email: email ?? this.email,
        note: note ?? this.note,
      );

  @override
  String toString() => 'Supplier(id: $id, name: $name, phone: $phone)';
}

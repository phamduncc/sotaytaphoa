class Category {
  final int? id;
  final String name;

  const Category({this.id, required this.name});

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as int?,
        name: map['name'] as String,
      );

  Category copyWith({int? id, String? name}) =>
      Category(id: id ?? this.id, name: name ?? this.name);

  @override
  String toString() => 'Category(id: $id, name: $name)';
}

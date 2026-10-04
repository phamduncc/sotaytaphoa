class AppTransaction {
  final int? id;
  final String type; // 'income' | 'expense'
  final double amount;
  final String date;
  final String description;

  const AppTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'type': type,
        'amount': amount,
        'date': date,
        'description': description,
      };

  factory AppTransaction.fromMap(Map<String, dynamic> map) => AppTransaction(
        id: map['id'] as int?,
        type: map['type'] as String,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        date: map['date'] as String,
        description: (map['description'] as String?) ?? '',
      );

  AppTransaction copyWith({
    int? id,
    String? type,
    double? amount,
    String? date,
    String? description,
  }) =>
      AppTransaction(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        description: description ?? this.description,
      );
}

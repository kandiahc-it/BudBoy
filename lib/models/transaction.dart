import 'dart:convert';

class Transaction {
  final String id;
  final double amount;
  final String category;
  final bool isCustomCategory;
  final DateTime date;
  final String note;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    this.isCustomCategory = false,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'isCustomCategory': isCustomCategory,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? 'Other',
      isCustomCategory: map['isCustomCategory'] ?? false,
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}

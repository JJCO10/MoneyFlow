class Transaction {
  final int? id;
  final double amount;
  final String type; // 'income' o 'expense'
  final int categoryId;
  final String description;
  final DateTime date;
  final bool isRecurring;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.description,
    required this.date,
    this.isRecurring = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'isRecurring': isRecurring ? 1 : 0,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      type: map['type'] as String,
      categoryId: map['categoryId'] as int,
      description: map['description'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      isRecurring: (map['isRecurring'] as int) == 1,
    );
  }
}
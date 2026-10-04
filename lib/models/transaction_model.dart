class Transaction {
  final int? id;
  final double amount;
  final String type; // 'income' o 'expense'
  final int categoryId;
  final String description;
  final DateTime date;
  final bool isRecurring;
  // 🔥 NUEVOS CAMPOS PARA RECURRENCIA
  final String? recurrenceType; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime? recurrenceEnd; // Fecha de fin (opcional)
  final int?
      parentId; // ID de la transacción original (para transacciones hijas)

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.description,
    required this.date,
    this.isRecurring = false,
    this.recurrenceType,
    this.recurrenceEnd,
    this.parentId,
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
      'recurrenceType': recurrenceType,
      'recurrenceEnd': recurrenceEnd?.millisecondsSinceEpoch,
      'parentId': parentId,
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
      recurrenceType: map['recurrenceType'] as String?,
      recurrenceEnd: map['recurrenceEnd'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['recurrenceEnd'] as int)
          : null,
      parentId: map['parentId'] as int?,
    );
  }

  // 🔥 MÉTODO PARA CREAR UNA COPIA CON NUEVOS VALORES
  Transaction copyWith({
    int? id,
    double? amount,
    String? type,
    int? categoryId,
    String? description,
    DateTime? date,
    bool? isRecurring,
    String? recurrenceType,
    DateTime? recurrenceEnd,
    int? parentId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      parentId: parentId ?? this.parentId,
    );
  }

  // 🔥 GETTER PARA OBTENER LA FRECUENCIA EN TEXTO
  String get recurrenceLabel {
    switch (recurrenceType) {
      case 'daily':
        return 'Diario';
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensual';
      case 'yearly':
        return 'Anual';
      default:
        return 'No recurrente';
    }
  }
}

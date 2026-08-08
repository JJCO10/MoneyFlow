class Budget {
  final int? id;
  final int categoryId;
  final double limit;
  final String period; // 'monthly', 'weekly'
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Budget({
    this.id,
    required this.categoryId,
    required this.limit,
    required this.period,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limit': limit,
      'period': period,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      categoryId: map['categoryId'] as int,
      limit: map['limit'] as double,
      period: map['period'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  }
}
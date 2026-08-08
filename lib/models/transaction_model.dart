import 'package:floor/floor.dart';

@Entity(tableName: 'Transaction')
class Transaction {
  @PrimaryKey(autoGenerate: true)
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
}
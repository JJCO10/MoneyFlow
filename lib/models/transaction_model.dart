import 'package:floor/floor.dart';

@Entity(tableName: 'transactions')
class Transaction {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final double amount;
  final String type; // 'income' o 'expense'
  final int categoryId;
  final String description;
  
  @ColumnInfo(name: 'date')
  final int dateTimestamp; // Guardamos como timestamp
  
  final bool isRecurring;
  
  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.description,
    required DateTime date,  // Recibimos DateTime
    this.isRecurring = false,
  }) : dateTimestamp = date.millisecondsSinceEpoch; // Convertimos a timestamp
  
  // Getter para obtener DateTime fácilmente
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
}
import 'package:floor/floor.dart';

@Entity(tableName: 'Category')
class Category {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final String type; // 'income' o 'expense'
  final String icon;
  final int color;
  final bool isDefault;
  
  Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });
}
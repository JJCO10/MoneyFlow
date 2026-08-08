class Category {
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String,
      color: map['color'] as int,
      isDefault: (map['isDefault'] as int) == 1,
    );
  }
}
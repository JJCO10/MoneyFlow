import 'package:flutter/material.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/theme/colors.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = category.type == 'income';
    final typeLabel = isIncome ? 'Ingreso' : 'Gasto';
    final typeColor = isIncome ? AppColors.secondary : AppColors.danger;
    final isDefault = category.isDefault;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.color).withOpacity(0.2),
          child: Text(
            category.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: typeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Por defecto',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, size: 20, color: AppColors.danger),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
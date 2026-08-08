import 'package:flutter/material.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String categoryName;
  final String categoryIcon;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // <-- Asegurar que existe

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.onTap,
    this.onDelete, // <-- Opcional
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? AppColors.secondary : AppColors.danger;
    final sign = isIncome ? '+' : '-';
    
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              categoryIcon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          title: Text(
            transaction.description,
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${DateFormat('dd/MM/yyyy').format(transaction.date)} • $categoryName',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Text(
            '$sign\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
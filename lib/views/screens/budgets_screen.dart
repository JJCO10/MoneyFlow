import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/budget_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/models/budget_model.dart';
import 'package:money_flow/l10n/translations.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BudgetController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textLight = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('budgets_title'.t),
        backgroundColor: Colors.transparent, // 🔥 TRANSPARENTE
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadBudgets(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.budgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'no_budgets'.t,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'add_budget_message'.t,
                  style: TextStyle(
                    color: textLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16).copyWith(bottom: 80),
          itemCount: controller.budgets.length,
          itemBuilder: (context, index) {
            final item = controller.budgets[index];
            final category = item['category'] as Category;
            final budget = item['budget'] as Budget?;
            final spent = item['spent'] as double;
            final progress = item['progress'] as double;
            final remaining = item['remaining'] as double;
            final isOverBudget = item['isOverBudget'] as bool;
            
            final color = Color(category.color);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Theme.of(context).cardColor,
              child: InkWell(
                onTap: budget == null
                    ? () => controller.showAddBudgetDialog(context, categoryId: category.id)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabecera con categoría y límite
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withOpacity(0.2),
                            child: Text(
                              category.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                                if (budget != null)
                                  Text(
                                    '${'limit'.t}: \$${budget.limit.toStringAsFixed(2)} • ${budget.period == 'monthly' ? 'monthly'.t : 'weekly'.t}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (budget != null)
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.danger),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: Text(
                                      'delete'.t,
                                      style: TextStyle(color: textPrimary),
                                    ),
                                    content: Text(
                                      '¿Estás seguro de eliminar el presupuesto de ${category.name}?',
                                      style: TextStyle(color: textSecondary),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text(
                                          'cancel'.t,
                                          style: TextStyle(color: textSecondary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller.deleteBudget(budget.id!);
                                          Get.back();
                                        },
                                        child: Text(
                                          'delete'.t,
                                          style: const TextStyle(color: AppColors.danger),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      
                      if (budget != null) ...[
                        const SizedBox(height: 12),
                        
                        // Barra de progreso
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${'spent'.t}: \$${spent.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                                Text(
                                  isOverBudget 
                                      ? 'over_budget'.t
                                      : '${progress.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isOverBudget ? AppColors.danger : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: isOverBudget ? 1.0 : progress / 100,
                                minHeight: 8,
                                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isOverBudget 
                                      ? AppColors.danger 
                                      : progress > 80 
                                          ? AppColors.warning 
                                          : AppColors.primary,
                                ),
                              ),
                            ),
                            if (!isOverBudget && remaining > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${'remaining'.t}: \$${remaining.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textLight,
                                  ),
                                ),
                              ),
                            if (isOverBudget)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${'exceeded_by'.t}: \$${(-remaining).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      
                      if (budget == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'set_budget'.t,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddBudgetDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
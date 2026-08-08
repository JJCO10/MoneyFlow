import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/home_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/screens/all_transactions_screen.dart';
import 'package:money_flow/views/screens/calendar_screen.dart';
import 'package:money_flow/views/screens/charts_screen.dart';
import 'package:money_flow/views/screens/edit_transaction_screen.dart';
import 'package:money_flow/views/screens/settings_screen.dart';
import 'package:money_flow/views/widgets/transaction_card.dart';
import 'package:money_flow/views/screens/add_transaction_screen.dart';
import 'package:money_flow/views/screens/categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyFlow'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Get.to(() => const AllTransactionsScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Get.to(() => const CalendarScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () => Get.to(() => const ChartsScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Get.to(() => const CategoriesScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de balances
                _buildBalanceSummary(controller, isDark),
                const SizedBox(height: 24),
                
                // Últimas transacciones
                _buildRecentTransactions(controller, isDark),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => AddTransactionScreen());
          if (result == true) {
            await controller.loadData();
            Get.snackbar(
              'Actualizado',
              'Los datos se han actualizado',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue,
              colorText: Colors.white,
              duration: const Duration(seconds: 1),
            );
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildBalanceSummary(HomeController controller, bool isDark) {
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Ingresos',
            '\$${controller.totalIncome.value.toStringAsFixed(2)}',
            AppColors.secondary,
            Icons.arrow_upward,
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Gastos',
            '\$${controller.totalExpense.value.toStringAsFixed(2)}',
            AppColors.danger,
            Icons.arrow_downward,
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Balance',
            '\$${controller.balance.value.toStringAsFixed(2)}',
            controller.balance.value >= 0 ? AppColors.primary : AppColors.danger,
            Icons.account_balance,
            textColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentTransactions(HomeController controller, bool isDark) {
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textLight = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    
    if (controller.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: isDark ? Colors.grey[600] : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay transacciones este mes',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presiona el botón + para agregar una',
                style: TextStyle(
                  color: textLight,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Últimos Movimientos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const AllTransactionsScreen()),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...controller.transactions.take(10).map((transaction) {
          return TransactionCard(
            transaction: transaction,
            categoryName: controller.getCategoryName(transaction.categoryId),
            categoryIcon: controller.getCategoryIcon(transaction.categoryId),
            onTap: () async {
              final result = await Get.to(() => EditTransactionScreen(
                transaction: transaction,
              ));
              if (result == true) {
                controller.loadData();
              }
            },
            onDelete: () => controller.deleteTransaction(transaction.id!),
          );
        }).toList(),
      ],
    );
  }
}
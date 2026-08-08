import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/home_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/transaction_card.dart';
import 'package:money_flow/views/screens/add_transaction_screen.dart';
import 'package:money_flow/views/screens/categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyFlow'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Get.to(() => const CategoriesScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Ir a configuración
              Get.snackbar('Info', 'Configuración en desarrollo');
            },
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
                _buildBalanceSummary(controller),
                const SizedBox(height: 24),
                
                // Últimas transacciones
                _buildRecentTransactions(controller),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Esperar el resultado de la pantalla de agregar
          final result = await Get.to(() => AddTransactionScreen());
          if (result == true) {
            // Recargar datos al regresar
            await controller.loadData();
            // Mostrar feedback visual
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
  
  Widget _buildBalanceSummary(HomeController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Ingresos',
            '\$${controller.totalIncome.value.toStringAsFixed(2)}',
            AppColors.secondary,
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Gastos',
            '\$${controller.totalExpense.value.toStringAsFixed(2)}',
            AppColors.danger,
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Balance',
            '\$${controller.balance.value.toStringAsFixed(2)}',
            controller.balance.value >= 0 ? AppColors.primary : AppColors.danger,
            Icons.account_balance,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
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
                  color: AppColors.textSecondary,
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
  
  Widget _buildRecentTransactions(HomeController controller) {
    if (controller.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No hay transacciones este mes',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presiona el botón + para agregar una',
                style: TextStyle(
                  color: AppColors.textLight,
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
            const Text(
              'Últimos Movimientos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Ver todas las transacciones
                Get.snackbar('Info', 'Ver todas en desarrollo');
              },
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
            onTap: () {
              // TODO: Ver detalle de transacción
              Get.snackbar('Info', 'Detalle en desarrollo');
            },
            onDelete: () => controller.deleteTransaction(transaction.id!),
          );
        }).toList(),
      ],
    );
  }
}
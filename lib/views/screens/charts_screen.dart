import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/chart_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/income_expense_chart.dart';
import 'package:money_flow/views/widgets/category_pie_chart.dart';
import 'package:money_flow/views/widgets/balance_line_chart.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChartController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final controller = Get.find<ChartController>();
              controller.loadChartData();
              Get.snackbar(
                'Actualizado',
                'Datos actualizados',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 1),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen
            _buildSummary(),
            const SizedBox(height: 24),
            
            // Gráfico de barras
            const Text(
              'Ingresos vs Gastos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const IncomeExpenseChart(),
            ),
            const SizedBox(height: 24),
            
            // Gráfico circular
            const Text(
              'Gastos por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const CategoryPieChart(),
            ),
            const SizedBox(height: 24),
            
            // Gráfico de líneas
            const Text(
              'Evolución del Balance Diario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const BalanceLineChart(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummary() {
    final controller = Get.find<ChartController>();
    
    return Obx(() {
      final income = controller.monthlyIncome.value;
      final expense = controller.monthlyExpense.value;
      final balance = income - expense;
      
      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Ingresos',
              '\$${income.toStringAsFixed(2)}',
              AppColors.secondary,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Gastos',
              '\$${expense.toStringAsFixed(2)}',
              AppColors.danger,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Balance',
              '\$${balance.toStringAsFixed(2)}',
              balance >= 0 ? AppColors.primary : AppColors.danger,
              Icons.account_balance,
            ),
          ),
        ],
      );
    });
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
}
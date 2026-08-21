import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/chart_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/income_expense_chart.dart';
import 'package:money_flow/views/widgets/category_pie_chart.dart';
import 'package:money_flow/views/widgets/balance_line_chart.dart';
import 'package:money_flow/l10n/translations.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChartController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('charts_title'.t),
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
                'info'.t,
                'data_updated'.t,
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
            _buildSummary(isDark),
            const SizedBox(height: 24),
            
            Text(
              'income_expense_chart'.t,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const IncomeExpenseChart(),
            ),
            const SizedBox(height: 24),
            
            Text(
              'category_pie_chart'.t,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const CategoryPieChart(),
            ),
            const SizedBox(height: 24),
            
            Text(
              'balance_line_chart'.t,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
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
  
  Widget _buildSummary(bool isDark) {
    final controller = Get.find<ChartController>();
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return Obx(() {
      final income = controller.monthlyIncome.value;
      final expense = controller.monthlyExpense.value;
      final balance = income - expense;
      
      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'income'.t,
              '\$${income.toStringAsFixed(2)}',
              AppColors.secondary,
              Icons.arrow_upward,
              textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'expense'.t,
              '\$${expense.toStringAsFixed(2)}',
              AppColors.danger,
              Icons.arrow_downward,
              textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'balance'.t,
              '\$${balance.toStringAsFixed(2)}',
              balance >= 0 ? AppColors.primary : AppColors.danger,
              Icons.account_balance,
              textSecondary,
            ),
          ),
        ],
      );
    });
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
}
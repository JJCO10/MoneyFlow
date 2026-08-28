import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/chart_controller.dart';
import 'package:money_flow/models/time_range.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/income_expense_chart.dart';
import 'package:money_flow/views/widgets/category_pie_chart.dart';
import 'package:money_flow/views/widgets/monthly_evolution_chart.dart';
import 'package:money_flow/views/widgets/annual_comparison_chart.dart';
import 'package:money_flow/l10n/translations.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChartController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('charts_title'.t),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        // 🔥 MOSTRAR INDICADOR DE CARGA SIEMPRE QUE isLoading SEA true
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando gráficos...'),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRangeSelector(controller, isDark),
              const SizedBox(height: 16),
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
                'monthly_evolution'.t,
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
                child: const MonthlyEvolutionChart(),
              ),
              const SizedBox(height: 24),
              
              Text(
                'annual_comparison'.t,
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
                child: const AnnualComparisonChart(),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildTimeRangeSelector(ChartController controller, bool isDark) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final bgColor = isDark ? AppColors.darkSurface : Colors.grey[100];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'time_range'.t,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Obx(() => DropdownButton<TimeRange>(
            value: controller.selectedRange.value,
            dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
            items: TimeRange.values.map((range) {
              return DropdownMenuItem<TimeRange>(
                value: range,
                child: Text(range.label),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.changeRange(value);
              }
            },
          )),
        ],
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
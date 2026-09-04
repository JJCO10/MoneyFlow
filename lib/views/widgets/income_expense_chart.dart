import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/chart_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/l10n/translations.dart';

class IncomeExpenseChart extends StatelessWidget {
  const IncomeExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      
      final income = controller.monthlyIncome.value;
      final expense = controller.monthlyExpense.value;
      
      // 🔥 Si no hay datos, mostrar mensaje
      if (income == 0 && expense == 0) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'no_data'.t,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 16,
              ),
            ),
          ),
        );
      }
      
      final maxValue = (income > expense ? income : expense) * 1.2;
      
      final gridColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      
      return SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue > 0 ? maxValue : 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: isDark ? Colors.grey[800]! : Colors.white,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '\$${rod.toY.toStringAsFixed(2)}',
                    TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const titles = ['income', 'expense'];
                    return Text(
                      titles[value.toInt()].t,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: gridColor,
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: income,
                    color: AppColors.secondary,
                    width: 40,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: expense,
                    color: AppColors.danger,
                    width: 40,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
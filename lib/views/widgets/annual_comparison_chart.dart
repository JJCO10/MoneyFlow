import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/chart_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/l10n/translations.dart';

class AnnualComparisonChart extends StatelessWidget {
  const AnnualComparisonChart({super.key});

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
      
      final data = controller.annualComparison;
      final hasData = data.any((item) => item['income'] > 0 || item['expense'] > 0);
      
      if (!hasData) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'no_annual_data'.t,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        );
      }
      
      final maxIncome = data.fold(0.0, (max, item) => 
        (item['income'] as double) > max ? (item['income'] as double) : max);
      final maxExpense = data.fold(0.0, (max, item) => 
        (item['expense'] as double) > max ? (item['expense'] as double) : max);
      final maxValue = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
      
      final gridColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      
      // 🔥 NOMBRES DE MESES TRADUCIBLES
      final months = [
        'jan'.t, 'feb'.t, 'mar'.t, 'apr'.t,
        'may'.t, 'jun'.t, 'jul'.t, 'aug'.t,
        'sep'.t, 'oct'.t, 'nov'.t, 'dec'.t
      ];
      
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
                  final item = data[group.x.toInt()];
                  final month = months[group.x.toInt()];
                  final value = rod.toY;
                  final type = rodIndex == 0 ? 'income_type_short'.t : 'expense_type_short'.t;
                  return BarTooltipItem(
                    '$month: $type \$${value.toStringAsFixed(2)}',
                    TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
                    if (value.toInt() < months.length) {
                      return Text(
                        months[value.toInt()],
                        style: TextStyle(
                          fontSize: 10,
                          color: textColor,
                        ),
                      );
                    }
                    return const Text('');
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
            barGroups: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: item['income'] as double,
                    color: AppColors.secondary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                  BarChartRodData(
                    toY: item['expense'] as double,
                    color: AppColors.danger,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
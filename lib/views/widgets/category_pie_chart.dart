import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/chart_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/l10n/translations.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 250,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      
      if (controller.categoryExpenses.isEmpty) {
        return SizedBox(
          height: 250,
          child: Center(
            child: Text(
              'no_expense_data'.t,
              style: TextStyle(color: textColor),
            ),
          ),
        );
      }
      
      final total = controller.categoryExpenses
          .fold(0.0, (sum, item) => sum + (item['amount'] as double));
      
      final colors = [
        const Color(0xFF3B82F6),
        const Color(0xFF10B981),
        const Color(0xFFF59E0B),
        const Color(0xFFEF4444),
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
        const Color(0xFF14B8A6),
        const Color(0xFFF97316),
        const Color(0xFF6366F1),
        const Color(0xFF06B6D4),
      ];
      
      return Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: List.generate(controller.categoryExpenses.length, (index) {
                  final item = controller.categoryExpenses[index];
                  final percentage = (item['amount'] as double) / total;
                  
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: item['amount'] as double,
                    title: '${(percentage * 100).toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                // 🔥 TOOLTIPS EN GRÁFICO CIRCULAR
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (pieTouchResponse?.touchedSection != null) {
                      final index = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                      final item = controller.categoryExpenses[index];
                      final percentage = ((item['amount'] as double) / total * 100);
                      Get.snackbar(
                        item['name'],
                        'Monto: \$${(item['amount'] as double).toStringAsFixed(2)}\nPorcentaje: ${percentage.toStringAsFixed(1)}%',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: colors[index % colors.length],
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: List.generate(controller.categoryExpenses.take(5).length, (index) {
              final item = controller.categoryExpenses[index];
              final percentage = ((item['amount'] as double) / total * 100);
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.grey[800] : Colors.grey[100])!,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item['icon']} ${item['name']} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}
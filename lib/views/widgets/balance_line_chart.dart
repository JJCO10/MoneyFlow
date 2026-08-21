import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/chart_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/l10n/translations.dart';

class BalanceLineChart extends StatelessWidget {
  const BalanceLineChart({super.key});

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
      
      if (controller.dailyBalances.length < 2) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'min_days_data'.t,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        );
      }
      
      final data = controller.dailyBalances;
      
      final values = data.map((item) => item['balance'] as double).toList();
      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final minValue = values.reduce((a, b) => a < b ? a : b);
      final range = maxValue - minValue;
      final padding = range * 0.2;
      final yMin = minValue - padding;
      final yMax = maxValue + padding;
      
      final gridColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      final textColor = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
      
      return SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (yMax - yMin) / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: gridColor,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < data.length) {
                      final day = data[value.toInt()]['day'] as String;
                      return Text(
                        day,
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
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: gridColor, width: 1),
            ),
            minX: 0,
            maxX: data.length - 1.0,
            minY: yMin,
            maxY: yMax,
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value['balance'] as double,
                  );
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.primary,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withOpacity(0.2),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
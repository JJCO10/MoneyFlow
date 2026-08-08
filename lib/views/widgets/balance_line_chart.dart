import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/chart_controller.dart';
import 'package:money_flow/theme/colors.dart';

class BalanceLineChart extends StatelessWidget {
  const BalanceLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChartController>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      
      if (controller.dailyBalances.length < 2) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Se necesitan al menos 2 días de datos',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }
      
      final data = controller.dailyBalances;
      
      // Encontrar valores mínimos y máximos para el eje Y
      final values = data.map((item) => item['balance'] as double).toList();
      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final minValue = values.reduce((a, b) => a < b ? a : b);
      final range = maxValue - minValue;
      final padding = range * 0.2;
      final yMin = minValue - padding;
      final yMax = maxValue + padding;
      
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
                  color: Colors.grey.shade300, // <-- CAMBIADO
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
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textLight,
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
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
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
              border: Border.all(color: Colors.grey.shade300!, width: 1), // <-- CAMBIADO
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
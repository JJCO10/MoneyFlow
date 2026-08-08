import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/home_controller.dart';

class BalanceChart extends StatelessWidget {
  final HomeController controller = Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dailyBalances.isEmpty) {
        return const Center(child: Text('Sin datos'));
      }
      
      final data = controller.dailyBalances.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      
      return SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() % 5 == 0 && value < data.length) {
                      return Text(
                        '${data[value.toInt()].key.day}',
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.value);
                }).toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.2),
                ),
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      );
    });
  }
}
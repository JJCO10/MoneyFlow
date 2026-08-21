  import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Servicio de gráficos para PDF.
///
/// El paquete `pdf` NO tiene una API de gráficos como `fl_chart`
/// (no existen BarChartGroupData, PieChartSectionData, FlSpot, etc.
/// esas clases son de fl_chart, otra librería distinta).
///
/// En vez de depender de los widgets `pw.Chart` / `BarDataSet` / `PieDataSet`
/// del paquete pdf (muy poco documentados y con el gráfico circular sin
/// implementar oficialmente), aquí se dibuja todo a mano con `pw.CustomPaint`,
/// que expone un canvas (`PdfGraphics`) con primitivas estables: líneas,
/// rectángulos y círculos.
class PdfChartService {
  static const double chartWidth = 460;
  static const double chartHeight = 160;

  // ==================== GRÁFICO DE BARRAS (Ingresos vs Gastos) ====================
  static pw.Widget buildBarChart({
    required double income,
    required double expense,
    required String title,
  }) {
    final maxValue = (income > expense ? income : expense) * 1.15;
    final safeMax = maxValue > 0 ? maxValue : 1.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: chartWidth,
          height: chartHeight,
          child: pw.CustomPaint(
            size: PdfPoint(chartWidth, chartHeight),
            painter: (PdfGraphics canvas, PdfPoint size) {
              const baseline = 20.0; // espacio inferior
              final usableHeight = size.y - baseline - 10;
              const barWidth = 70.0;
              const gap = 60.0;
              final startX = (size.x - (barWidth * 2 + gap)) / 2;

              // Eje base
              canvas
                ..setColor(PdfColors.grey400)
                ..setLineWidth(1)
                ..moveTo(10, baseline)
                ..lineTo(size.x - 10, baseline)
                ..strokePath();

              // Barra de Ingresos
              final incomeHeight = (income / safeMax) * usableHeight;
              canvas
                ..setColor(PdfColors.green)
                ..drawRect(startX, baseline, barWidth, incomeHeight)
                ..fillPath();

              // Barra de Gastos
              final expenseHeight = (expense / safeMax) * usableHeight;
              canvas
                ..setColor(PdfColors.red)
                ..drawRect(startX + barWidth + gap, baseline, barWidth, expenseHeight)
                ..fillPath();
            },
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Ingresos', '\$${income.toStringAsFixed(2)}', PdfColors.green),
            _buildLegendItem('Gastos', '\$${expense.toStringAsFixed(2)}', PdfColors.red),
          ],
        ),
      ],
    );
  }

  // ==================== DESGLOSE DE GASTOS POR CATEGORÍA ====================
  // Reemplaza al gráfico circular: el pie chart del paquete pdf no está
  // oficialmente implementado y es poco confiable. Esta lista con barras
  // de porcentaje horizontales comunica lo mismo de forma más estable.
  static pw.Widget buildCategoryBreakdown({
    required Map<String, double> data,
    required String title,
  }) {
    if (data.isEmpty) {
      return pw.Text('No hay datos de gastos para mostrar');
    }

    final total = data.values.fold(0.0, (sum, v) => sum + v);
    final colors = [
      PdfColors.blue,
      PdfColors.green,
      PdfColors.red,
      PdfColors.orange,
      PdfColors.purple,
      PdfColors.pink,
      PdfColors.teal,
      PdfColors.brown,
      PdfColors.grey,
      PdfColors.indigo,
    ];

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        ...sortedEntries.take(8).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final percentage = item.value / total;
          final color = colors[index % colors.length];

          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 8,
                          height: 8,
                          decoration: pw.BoxDecoration(
                            color: color,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(item.key, style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Text(
                      '\$${item.value.toStringAsFixed(2)} (${(percentage * 100).toStringAsFixed(1)}%)',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Stack(
                  children: [
                    pw.Container(
                      height: 8,
                      width: chartWidth,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                    pw.Container(
                      height: 8,
                      width: chartWidth * percentage,
                      decoration: pw.BoxDecoration(
                        color: color,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        pw.SizedBox(height: 4),
        pw.Text(
          'Total Gastos: \$${total.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  // ==================== GRÁFICO DE LÍNEAS (Balance diario) ====================
  static pw.Widget buildLineChart({
    required List<Map<String, dynamic>> dailyBalances,
    required String title,
  }) {
    if (dailyBalances.length < 2) {
      return pw.Text('Se necesitan al menos 2 días de datos para el gráfico de línea');
    }

    final values = dailyBalances.map((item) => item['balance'] as double).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs();
    final padding = range > 0 ? range * 0.15 : 10.0;
    final yMin = minValue - padding;
    final yMax = maxValue + padding;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: chartWidth,
          height: chartHeight,
          child: pw.CustomPaint(
            size: PdfPoint(chartWidth, chartHeight),
            painter: (PdfGraphics canvas, PdfPoint size) {
              const leftMargin = 10.0;
              const rightMargin = 10.0;
              const topMargin = 10.0;
              const bottomMargin = 20.0;
              final plotWidth = size.x - leftMargin - rightMargin;
              final plotHeight = size.y - topMargin - bottomMargin;

              // Eje base
              canvas
                ..setColor(PdfColors.grey400)
                ..setLineWidth(1)
                ..moveTo(leftMargin, bottomMargin)
                ..lineTo(size.x - rightMargin, bottomMargin)
                ..strokePath();

              double xFor(int index) =>
                  leftMargin + (plotWidth * index / (values.length - 1));
              double yFor(double value) =>
                  bottomMargin + ((value - yMin) / (yMax - yMin)) * plotHeight;

              // Línea conectando los puntos
              canvas
                ..setColor(PdfColors.blue)
                ..setLineWidth(2)
                ..moveTo(xFor(0), yFor(values[0]));
              for (var i = 1; i < values.length; i++) {
                canvas.lineTo(xFor(i), yFor(values[i]));
              }
              canvas.strokePath();

              // Puntos sobre la línea
              for (var i = 0; i < values.length; i++) {
                canvas
                  ..setColor(PdfColors.blue)
                  ..drawEllipse(xFor(i), yFor(values[i]), 2.5, 2.5)
                  ..fillPath();
              }
            },
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              dailyBalances.first['day'].toString(),
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              dailyBalances.last['day'].toString(),
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Balance final: \$${(dailyBalances.last['balance'] as double).toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  // ==================== LEYENDA ====================
  static pw.Widget _buildLegendItem(String label, String value, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            color: color,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          '$label: $value',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
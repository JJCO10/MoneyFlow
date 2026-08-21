import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:money_flow/utils/file_share_channel.dart';
import 'package:money_flow/services/pdf_chart_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:intl/intl.dart';

class PdfExportService extends GetxService {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();

  Future<void> export(DateTime month) async {
    try {
      print('📊 Iniciando exportación a PDF con gráficos nativos...');

      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final transactions = await _transactionService.getTransactionsBetween(
        startOfMonth,
        endOfMonth,
      );

      if (transactions.isEmpty) {
        Get.snackbar(
          'Sin datos',
          'No hay transacciones para exportar en este mes',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final categories = await _categoryService.getAllCategories();

      final categoryMap = <int, String>{};
      for (var cat in categories) {
        categoryMap[cat.id!] = cat.name;
      }

      final totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = transactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      final balance = totalIncome - totalExpense;

      // ==================== DATOS PARA GRÁFICOS ====================
      // 1. Gastos por categoría
      final expenseByCategory = <String, double>{};
      for (var t in transactions.where((t) => t.type == 'expense')) {
        final catName = categoryMap[t.categoryId] ?? 'Sin categoría';
        expenseByCategory[catName] = (expenseByCategory[catName] ?? 0) + t.amount;
      }

      // 2. Balances diarios
      final dailyBalances = <Map<String, dynamic>>[];
      final Map<String, double> dailyMap = {};
      for (var t in transactions) {
        final dateKey = '${t.date.day}/${t.date.month}';
        final amount = t.type == 'income' ? t.amount : -t.amount;
        dailyMap[dateKey] = (dailyMap[dateKey] ?? 0) + amount;
      }
      final sortedKeys = dailyMap.keys.toList()..sort((a, b) {
        final partsA = a.split('/');
        final partsB = b.split('/');
        final dayA = int.parse(partsA[0]);
        final dayB = int.parse(partsB[0]);
        return dayA.compareTo(dayB);
      });
      for (var key in sortedKeys) {
        dailyBalances.add({'day': key, 'balance': dailyMap[key] ?? 0.0});
      }

      // ==================== CREAR PDF ====================
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (context) => [
            // ENCABEZADO
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    '📊 MoneyFlow - Reporte Mensual',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    DateFormat('MMMM yyyy').format(month),
                    style: pw.TextStyle(
                      fontSize: 18,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // RESUMEN
            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryItem('Ingresos', '\$${totalIncome.toStringAsFixed(2)}', PdfColors.green),
                  _buildSummaryItem('Gastos', '\$${totalExpense.toStringAsFixed(2)}', PdfColors.red),
                  _buildSummaryItem('Balance', '\$${balance.toStringAsFixed(2)}',
                    balance >= 0 ? PdfColors.blue : PdfColors.red),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // GRÁFICO DE BARRAS (Ingresos vs Gastos)
            PdfChartService.buildBarChart(
              income: totalIncome,
              expense: totalExpense,
              title: 'Ingresos vs Gastos del Mes',
            ),
            pw.SizedBox(height: 16),

            // GRÁFICO CIRCULAR (Gastos por categoría)
            PdfChartService.buildCategoryBreakdown(
              data: expenseByCategory,
              title: 'Distribución de Gastos por Categoría',
            ),
            pw.SizedBox(height: 16),

            // TABLA DE TRANSACCIONES
            pw.Text(
              'Detalle de Transacciones',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['Fecha', 'Tipo', 'Categoría', 'Descripción', 'Monto'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 11,
              ),
              cellStyle: pw.TextStyle(fontSize: 9),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.blue100,
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                ),
              ),
              data: transactions.map((t) {
                final type = t.type == 'income' ? 'Ingreso' : 'Gasto';
                final categoryName = categoryMap[t.categoryId] ?? 'Sin categoría';
                final dateStr = DateFormat('dd/MM/yyyy').format(t.date);
                final amount = t.type == 'income'
                    ? t.amount.toStringAsFixed(2)
                    : '-${t.amount.toStringAsFixed(2)}';

                return [
                  dateStr,
                  type,
                  categoryName,
                  t.description,
                  amount,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 16),

            // RESULTADOS FINALES
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  _buildSummaryRow('Total Ingresos:', '\$${totalIncome.toStringAsFixed(2)}', PdfColors.green),
                  _buildSummaryRow('Total Gastos:', '\$${totalExpense.toStringAsFixed(2)}', PdfColors.red),
                  _buildSummaryRow('Balance:', '\$${balance.toStringAsFixed(2)}',
                    balance >= 0 ? PdfColors.blue : PdfColors.red),
                  pw.Divider(),
                  _buildSummaryRow('Total Transacciones:', transactions.length.toString(), PdfColors.grey600),
                ],
              ),
            ),

            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Text(
                'Reporte generado automáticamente por MoneyFlow',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey400,
                ),
              ),
            ),
          ],
        ),
      );

      final directory = await getTemporaryDirectory();
      final fileName = 'reporte_${DateFormat('yyyyMM').format(month)}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print('✅ PDF guardado en: $filePath');

      final shared = await FileShareChannel.shareFile(filePath, 'application/pdf');
      if (shared) {
        Get.snackbar(
          'Éxito',
          'Archivo PDF exportado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error exportando PDF: $e');
      Get.snackbar(
        'Error',
        'No se pudo exportar el PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  pw.Widget _buildSummaryRow(String label, String value, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}
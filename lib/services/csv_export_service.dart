import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:money_flow/utils/file_share_channel.dart';
import 'package:csv/csv.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:intl/intl.dart';

class CsvExportService extends GetxService {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();

  Future<void> export(DateTime month) async {
    try {
      print('📊 Iniciando exportación a CSV...');

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

      // ==================== FORMATO TABLA CSV ====================
      final List<List<String>> rows = [];
      
      // Encabezados
      rows.add(['FECHA', 'TIPO', 'CATEGORÍA', 'DESCRIPCIÓN', 'MONTO']);
      rows.add(['-' * 10, '-' * 10, '-' * 10, '-' * 20, '-' * 10]);

      // Datos
      for (var t in transactions) {
        final type = t.type == 'income' ? 'INGRESO' : 'GASTO';
        final categoryName = categoryMap[t.categoryId] ?? 'Sin categoría';
        final dateStr = DateFormat('yyyy-MM-dd').format(t.date);
        final amount = t.type == 'income'
            ? t.amount.toStringAsFixed(2)
            : '-${t.amount.toStringAsFixed(2)}';

        rows.add([dateStr, type, categoryName, t.description, amount]);
      }

      // Separador final
      rows.add(['-' * 10, '-' * 10, '-' * 10, '-' * 20, '-' * 10]);

      // Resumen
      final totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = transactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      final balance = totalIncome - totalExpense;

      rows.add([]);
      rows.add(['=== RESUMEN DEL MES ===']);
      rows.add([]);
      rows.add(['Total Ingresos:', totalIncome.toStringAsFixed(2)]);
      rows.add(['Total Gastos:', totalExpense.toStringAsFixed(2)]);
      rows.add(['Balance:', balance.toStringAsFixed(2)]);
      rows.add([]);
      rows.add(['Total Transacciones:', transactions.length.toString()]);

      final csv = const ListToCsvConverter().convert(rows);

      final directory = await getTemporaryDirectory();
      final fileName = 'reporte_${DateFormat('yyyyMM').format(month)}.csv';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csv, encoding: utf8);

      print('✅ CSV guardado en: $filePath');

      final shared = await FileShareChannel.shareFile(filePath, 'text/csv');
      if (shared) {
        Get.snackbar(
          'Éxito',
          'Archivo CSV exportado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error exportando CSV: $e');
      Get.snackbar(
        'Error',
        'No se pudo exportar el CSV: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
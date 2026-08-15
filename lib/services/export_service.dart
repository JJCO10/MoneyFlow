import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:intl/intl.dart';
import 'package:money_flow/utils/app_info.dart';

class ExportService extends GetxService {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();

  // Obtener URI para compartir archivos (compatible con Android 7+)
  Future<Uri> _getFileUri(File file) async {
    print('📁 Archivo: ${file.path}');
    print('📁 Nombre del archivo: ${file.path.split('/').last}');
    
    // En Android, usar content:// en lugar de file://
    if (Platform.isAndroid) {
      try {
        final packageName = AppInfo.getPackageName();
        final fileName = file.path.split('/').last;
        
        // La URI debe incluir la ruta relativa desde la raíz del cache
        // Usamos cache-path con path="/" para que el archivo esté en la raíz del cache
        final uri = Uri.parse('content://$packageName.fileprovider/cache/$fileName');
        print('📱 URI generada: $uri');
        return uri;
      } catch (e) {
        print('⚠️ Error generando content URI: $e, usando file://');
        return Uri.file(file.path);
      }
    }
    return Uri.file(file.path);
  }

  // ==================== EXPORTAR A CSV ====================
  Future<void> exportToCSV(DateTime month) async {
    try {
      print('📊 Iniciando exportación a CSV...');
      
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      
      print('📅 Rango de fechas: ${DateFormat('dd/MM/yyyy').format(startOfMonth)} - ${DateFormat('dd/MM/yyyy').format(endOfMonth)}');
      
      final transactions = await _transactionService.getTransactionsBetween(
        startOfMonth,
        endOfMonth,
      );
      
      print('📊 Transacciones encontradas: ${transactions.length}');
      
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
      
      final List<List<String>> rows = [];
      rows.add(['Fecha', 'Tipo', 'Categoría', 'Descripción', 'Monto']);
      
      for (var t in transactions) {
        final type = t.type == 'income' ? 'Ingreso' : 'Gasto';
        final categoryName = categoryMap[t.categoryId] ?? 'Sin categoría';
        final dateStr = DateFormat('dd/MM/yyyy').format(t.date);
        final amount = t.type == 'income' 
            ? t.amount.toStringAsFixed(2) 
            : '-${t.amount.toStringAsFixed(2)}';
        
        rows.add([dateStr, type, categoryName, t.description, amount]);
      }
      
      final totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = transactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      final balance = totalIncome - totalExpense;
      
      rows.add([]);
      rows.add(['=== RESUMEN ===', '', '', '', '']);
      rows.add(['Total Ingresos', '', '', '', totalIncome.toStringAsFixed(2)]);
      rows.add(['Total Gastos', '', '', '', totalExpense.toStringAsFixed(2)]);
      rows.add(['Balance', '', '', '', balance.toStringAsFixed(2)]);
      
      final csv = const ListToCsvConverter().convert(rows);
      
      final directory = await getTemporaryDirectory();
      print('📁 Directorio temporal: ${directory.path}');
      
      final fileName = 'reporte_${DateFormat('yyyyMM').format(month)}.csv';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csv, encoding: utf8);
      
      print('✅ CSV guardado en: $filePath');
      print('📄 Tamaño del archivo: ${await file.length()} bytes');
      
      // Verificar que el archivo existe
      if (!await file.exists()) {
        throw Exception('El archivo no se creó correctamente');
      }
      
      // Usar content URI para Android
      final uri = await _getFileUri(file);
      print('📱 URI para compartir: $uri');
      
      // Verificar si se puede lanzar la URI
      final canLaunch = await canLaunchUrl(uri);
      print('🔗 ¿Se puede lanzar? $canLaunch');
      
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ URL lanzada correctamente');
        
        Get.snackbar(
          'Éxito',
          'Archivo CSV exportado correctamente: $fileName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Intentar con file:// como fallback
        print('⚠️ No se pudo abrir con content URI, intentando con file://');
        final fileUri = Uri.file(filePath);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri, mode: LaunchMode.externalApplication);
          Get.snackbar(
            'Éxito',
            'Archivo CSV exportado correctamente: $fileName',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          throw 'No se puede abrir el archivo CSV';
        }
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

  // ==================== EXPORTAR A PDF ====================
  Future<void> exportToPDF(DateTime month) async {
    try {
      print('📊 Iniciando exportación a PDF...');
      
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      
      print('📅 Rango de fechas: ${DateFormat('dd/MM/yyyy').format(startOfMonth)} - ${DateFormat('dd/MM/yyyy').format(endOfMonth)}');
      
      final transactions = await _transactionService.getTransactionsBetween(
        startOfMonth,
        endOfMonth,
      );
      
      print('📊 Transacciones encontradas: ${transactions.length}');
      
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
      
      print('💰 Ingresos: \$${totalIncome.toStringAsFixed(2)}');
      print('💰 Gastos: \$${totalExpense.toStringAsFixed(2)}');
      print('💰 Balance: \$${balance.toStringAsFixed(2)}');
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'MoneyFlow - Reporte Mensual',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    DateFormat('MMMM yyyy').format(month),
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 8),
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
            pw.SizedBox(height: 24),
            
            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
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
            pw.SizedBox(height: 24),
            
            pw.Text(
              'Transacciones',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['Fecha', 'Tipo', 'Categoría', 'Descripción', 'Monto'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.blue100,
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
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
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Ingresos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('\$${totalIncome.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.green)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Gastos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('\$${totalExpense.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.red)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Balance:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('\$${balance.toStringAsFixed(2)}', 
                        style: pw.TextStyle(color: balance >= 0 ? PdfColors.blue : PdfColors.red)),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Transacciones:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(transactions.length.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      
      final directory = await getTemporaryDirectory();
      print('📁 Directorio temporal: ${directory.path}');
      
      final fileName = 'reporte_${DateFormat('yyyyMM').format(month)}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      print('✅ PDF guardado en: $filePath');
      print('📄 Tamaño del archivo: ${await file.length()} bytes');
      
      // Verificar que el archivo existe
      if (!await file.exists()) {
        throw Exception('El archivo no se creó correctamente');
      }
      
      // Usar content URI para Android
      final uri = await _getFileUri(file);
      print('📱 URI para compartir: $uri');
      
      // Verificar si se puede lanzar la URI
      final canLaunch = await canLaunchUrl(uri);
      print('🔗 ¿Se puede lanzar? $canLaunch');
      
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ URL lanzada correctamente');
        
        Get.snackbar(
          'Éxito',
          'Archivo PDF exportado correctamente: $fileName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Intentar con file:// como fallback
        print('⚠️ No se pudo abrir con content URI, intentando con file://');
        final fileUri = Uri.file(filePath);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri, mode: LaunchMode.externalApplication);
          Get.snackbar(
            'Éxito',
            'Archivo PDF exportado correctamente: $fileName',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          throw 'No se puede abrir el archivo PDF';
        }
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
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/services/budget_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/models/budget_model.dart';
import 'package:intl/intl.dart';

class BackupService extends GetxService {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();
  final BudgetService _budgetService = Get.find();

  // ==================== EXPORTAR BACKUP ====================
  Future<File?> exportBackup() async {
    try {
      print('📦 Iniciando exportación de backup...');

      // Obtener todos los datos
      final categories = await _categoryService.getAllCategories();
      final transactions = await _transactionService.getAllTransactions();
      final budgets = await _budgetService.getAllBudgets();

      // Crear objeto de backup
      final backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'data': {
          'categories': categories.map((c) => {
            'id': c.id,
            'name': c.name,
            'type': c.type,
            'icon': c.icon,
            'color': c.color,
            'isDefault': c.isDefault,
          }).toList(),
          'transactions': transactions.map((t) => {
            'id': t.id,
            'amount': t.amount,
            'type': t.type,
            'categoryId': t.categoryId,
            'description': t.description,
            'date': t.date.toIso8601String(),
            'isRecurring': t.isRecurring,
          }).toList(),
          'budgets': budgets.map((b) => {
            'id': b.id,
            'categoryId': b.categoryId,
            'limit': b.limit,
            'period': b.period,
            'createdAt': b.createdAt.toIso8601String(),
            'updatedAt': b.updatedAt?.toIso8601String(),
          }).toList(),
        },
      };

      // Convertir a JSON
      final jsonString = jsonEncode(backupData);

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString, encoding: utf8);

      print('✅ Backup exportado: $filePath');
      print('📊 Categorías: ${categories.length}');
      print('📊 Transacciones: ${transactions.length}');
      print('📊 Presupuestos: ${budgets.length}');

      return file;
    } catch (e) {
      print('❌ Error exportando backup: $e');
      return null;
    }
  }

  // ==================== IMPORTAR BACKUP ====================
  Future<bool> importBackup(File file) async {
    try {
      print('📦 Iniciando importación de backup...');

      // Leer archivo
      final jsonString = await file.readAsString(encoding: utf8);
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      // Validar versión
      if (backupData['version'] != '1.0') {
        throw Exception('Versión de backup no compatible');
      }

      final data = backupData['data'];

      // 🔥 IMPORTAR CATEGORÍAS
      final categories = (data['categories'] as List).map((c) => Category(
        id: c['id'],
        name: c['name'],
        type: c['type'],
        icon: c['icon'],
        color: c['color'],
        isDefault: c['isDefault'] ?? false,
      )).toList();

      // 🔥 IMPORTAR TRANSACCIONES
      final transactions = (data['transactions'] as List).map((t) => Transaction(
        id: t['id'],
        amount: t['amount'],
        type: t['type'],
        categoryId: t['categoryId'],
        description: t['description'],
        date: DateTime.parse(t['date']),
        isRecurring: t['isRecurring'] ?? false,
      )).toList();

      // 🔥 IMPORTAR PRESUPUESTOS
      final budgets = (data['budgets'] as List).map((b) => Budget(
        id: b['id'],
        categoryId: b['categoryId'],
        limit: b['limit'],
        period: b['period'],
        createdAt: DateTime.parse(b['createdAt']),
        updatedAt: b['updatedAt'] != null ? DateTime.parse(b['updatedAt']) : null,
      )).toList();

      print('📊 Categorías a importar: ${categories.length}');
      print('📊 Transacciones a importar: ${transactions.length}');
      print('📊 Presupuestos a importar: ${budgets.length}');

      // Confirmar importación
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar importación'),
          content: Text(
            'Se importarán:\n'
            '• ${categories.length} categorías\n'
            '• ${transactions.length} transacciones\n'
            '• ${budgets.length} presupuestos\n\n'
            '¿Deseas continuar? Los datos actuales serán reemplazados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        print('❌ Importación cancelada por el usuario');
        return false;
      }

      // 🔥 LIMPIAR DATOS EXISTENTES
      print('🧹 Eliminando datos existentes...');
      
      // Eliminar transacciones
      final allTransactions = await _transactionService.getAllTransactions();
      for (var t in allTransactions) {
        await _transactionService.deleteTransaction(t.id!);
      }

      // Eliminar presupuestos
      final allBudgets = await _budgetService.getAllBudgets();
      for (var b in allBudgets) {
        await _budgetService.deleteBudget(b.id!);
      }

      // Eliminar categorías (excepto las por defecto del sistema)
      final allCategories = await _categoryService.getAllCategories();
      for (var c in allCategories) {
        await _categoryService.deleteCategory(c.id!);
      }

      // 🔥 INSERTAR NUEVOS DATOS
      print('📥 Insertando nuevos datos...');

      for (var category in categories) {
        await _categoryService.saveCategory(category);
      }

      for (var transaction in transactions) {
        await _transactionService.saveTransaction(transaction);
      }

      for (var budget in budgets) {
        await _budgetService.saveBudget(budget);
      }

      print('✅ Importación completada exitosamente');
      return true;

    } catch (e) {
      print('❌ Error importando backup: $e');
      
      // Mostrar mensaje de error
      Get.snackbar(
        'Error',
        'No se pudo importar el backup: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      return false;
    }
  }

  // ==================== OBTENER INFORMACIÓN DEL BACKUP ====================
  Future<Map<String, dynamic>?> getBackupInfo(File file) async {
    try {
      final jsonString = await file.readAsString(encoding: utf8);
      final Map<String, dynamic> backupData = jsonDecode(jsonString);
      
      return {
        'version': backupData['version'],
        'exportDate': backupData['exportDate'],
        'categories': (backupData['data']['categories'] as List).length,
        'transactions': (backupData['data']['transactions'] as List).length,
        'budgets': (backupData['data']['budgets'] as List).length,
      };
    } catch (e) {
      return null;
    }
  }
}
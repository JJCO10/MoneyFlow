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
import 'package:money_flow/l10n/translations.dart';
import 'package:intl/intl.dart';

class BackupService extends GetxService {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();
  final BudgetService _budgetService = Get.find();

  // ==================== EXPORTAR BACKUP ====================
  Future<File?> exportBackup() async {
    try {
      print('📦 Iniciando exportación de backup...');

      final categories = await _categoryService.getAllCategories();
      final transactions = await _transactionService.getAllTransactions();
      final budgets = await _budgetService.getAllBudgets();

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

      final jsonString = jsonEncode(backupData);

      // Guardar en Descargas
      String directoryPath;
      final possiblePaths = [
        '/storage/emulated/0/Download/',
        '/sdcard/Download/',
        '/storage/emulated/0/download/',
        '/sdcard/download/',
      ];
      
      Directory? downloadDir;
      for (var path in possiblePaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          downloadDir = dir;
          break;
        }
      }
      
      if (downloadDir == null) {
        final docsDir = await getApplicationDocumentsDirectory();
        downloadDir = docsDir;
        print('⚠️ Usando directorio de documentos: ${downloadDir.path}');
      }
      
      print('📁 Directorio de backup: ${downloadDir.path}');
      
      final fileName = 'backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
      final filePath = '${downloadDir.path}/$fileName';
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

      final jsonString = await file.readAsString(encoding: utf8);
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      if (backupData['version'] != '1.0') {
        throw Exception('Versión de backup no compatible');
      }

      final data = backupData['data'];

      final oldCategories = (data['categories'] as List).map((c) => Category(
        id: c['id'],
        name: c['name'],
        type: c['type'],
        icon: c['icon'],
        color: c['color'],
        isDefault: c['isDefault'] ?? false,
      )).toList();

      final oldTransactions = (data['transactions'] as List).map((t) => Transaction(
        id: t['id'],
        amount: t['amount'],
        type: t['type'],
        categoryId: t['categoryId'],
        description: t['description'],
        date: DateTime.parse(t['date']),
        isRecurring: t['isRecurring'] ?? false,
      )).toList();

      final oldBudgets = (data['budgets'] as List).map((b) => Budget(
        id: b['id'],
        categoryId: b['categoryId'],
        limit: b['limit'],
        period: b['period'],
        createdAt: DateTime.parse(b['createdAt']),
        updatedAt: b['updatedAt'] != null ? DateTime.parse(b['updatedAt']) : null,
      )).toList();

      print('📊 Categorías a importar: ${oldCategories.length}');
      print('📊 Transacciones a importar: ${oldTransactions.length}');
      print('📊 Presupuestos a importar: ${oldBudgets.length}');

      print('📥 Iniciando importación...');

      // LIMPIAR DATOS EXISTENTES
      print('🧹 Eliminando datos existentes...');
      
      final allTransactions = await _transactionService.getAllTransactions();
      for (var t in allTransactions) {
        await _transactionService.deleteTransaction(t.id!);
      }

      final allBudgets = await _budgetService.getAllBudgets();
      for (var b in allBudgets) {
        await _budgetService.deleteBudget(b.id!);
      }

      final allCategories = await _categoryService.getAllCategories();
      for (var c in allCategories) {
        await _categoryService.deleteCategory(c.id!);
      }

      // INSERTAR CATEGORÍAS
      print('📥 Insertando categorías...');
      final Map<int, int> categoryIdMap = {};
      
      for (var category in oldCategories) {
        final oldId = category.id!;
        final newCategory = Category(
          name: category.name,
          type: category.type,
          icon: category.icon,
          color: category.color,
          isDefault: category.isDefault,
        );
        await _categoryService.saveCategory(newCategory);
        final savedCategories = await _categoryService.getAllCategories();
        final savedCategory = savedCategories.firstWhere(
          (c) => c.name == category.name && c.type == category.type,
          orElse: () => savedCategories.last,
        );
        categoryIdMap[oldId] = savedCategory.id!;
        print('   ${category.name} (${category.type}): ID viejo $oldId → nuevo ${savedCategory.id}');
      }

      // INSERTAR TRANSACCIONES
      print('📥 Insertando transacciones...');
      for (var transaction in oldTransactions) {
        final newCategoryId = categoryIdMap[transaction.categoryId];
        if (newCategoryId == null) {
          print('   ⚠️ Saltando transacción: categoría ${transaction.categoryId} no encontrada');
          continue;
        }
        
        final newTransaction = Transaction(
          amount: transaction.amount,
          type: transaction.type,
          categoryId: newCategoryId,
          description: transaction.description,
          date: transaction.date,
          isRecurring: transaction.isRecurring,
        );
        await _transactionService.saveTransaction(newTransaction);
        print('   ✅ ${transaction.description} - \$${transaction.amount}');
      }

      // INSERTAR PRESUPUESTOS
      print('📥 Insertando presupuestos...');
      for (var budget in oldBudgets) {
        final newCategoryId = categoryIdMap[budget.categoryId];
        if (newCategoryId == null) {
          print('   ⚠️ Saltando presupuesto: categoría ${budget.categoryId} no encontrada');
          continue;
        }
        
        final newBudget = Budget(
          categoryId: newCategoryId,
          limit: budget.limit,
          period: budget.period,
          createdAt: budget.createdAt,
          updatedAt: budget.updatedAt,
        );
        await _budgetService.saveBudget(newBudget);
        print('   ✅ Presupuesto para categoría ID $newCategoryId: \$${budget.limit}');
      }

      print('✅ Importación completada exitosamente');
      return true;

    } catch (e) {
      print('❌ Error importando backup: $e');
      
      Get.snackbar(
        'Error',
        'backup_import_error'.t,
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
      print('📄 Leyendo archivo: ${file.path}');
      
      // Verificar si el archivo existe
      if (!await file.exists()) {
        print('❌ El archivo no existe: ${file.path}');
        return null;
      }
      
      print('📄 Tamaño del archivo: ${await file.length()} bytes');
      
      final jsonString = await file.readAsString(encoding: utf8);
      print('📄 Contenido leído correctamente');
      
      final Map<String, dynamic> backupData = jsonDecode(jsonString);
      print('📄 JSON parseado correctamente');
      
      final categories = (backupData['data']?['categories'] as List?)?.length ?? 0;
      final transactions = (backupData['data']?['transactions'] as List?)?.length ?? 0;
      final budgets = (backupData['data']?['budgets'] as List?)?.length ?? 0;
      
      print('📊 Categorías encontradas: $categories');
      print('📊 Transacciones encontradas: $transactions');
      print('📊 Presupuestos encontrados: $budgets');
      
      return {
        'version': backupData['version'] ?? '1.0',
        'exportDate': backupData['exportDate'] ?? 'Fecha desconocida',
        'categories': categories,
        'transactions': transactions,
        'budgets': budgets,
      };
    } catch (e) {
      print('❌ Error leyendo backup: $e');
      print('❌ Stacktrace: ${StackTrace.current}');
      return null;
    }
  }
}
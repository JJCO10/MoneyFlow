import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';

class HomeController extends GetxController {
  final CategoryService _categoryService = Get.find();
  final TransactionService _transactionService = Get.find();
  
  // Observables
  var isLoading = false.obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var balance = 0.0.obs;
  var transactions = <Transaction>[].obs;
  var categories = <Category>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Cargar categorías
      categories.value = await _categoryService.getAllCategories();
      
      // Cargar transacciones del mes
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      transactions.value = await _transactionService.getTransactionsBetween(
        startOfMonth,
        endOfMonth,
      );
      
      // Calcular totales
      totalIncome.value = transactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.amount);
          
      totalExpense.value = transactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
          
      balance.value = totalIncome.value - totalExpense.value;
      
    } catch (e) {
      print('❌ Error cargando datos: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Obtener el nombre de la categoría por ID
  String getCategoryName(int categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.name ?? 'Sin categoría';
  }
  
  // Obtener el ícono de la categoría por ID
  String getCategoryIcon(int categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.icon ?? '📌';
  }
  
  // Eliminar transacción
  Future<void> deleteTransaction(int id) async {
    try {
      await _transactionService.deleteTransaction(id);
      await loadData(); // Recargar datos
      
      Get.snackbar(
        'Éxito',
        'Transacción eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la transacción',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  // Obtener transacciones por tipo
  List<Transaction> getTransactionsByType(String type) {
    return transactions.where((t) => t.type == type).toList();
  }
  
  // Obtener transacciones por categoría
  List<Transaction> getTransactionsByCategory(int categoryId) {
    return transactions.where((t) => t.categoryId == categoryId).toList();
  }
}
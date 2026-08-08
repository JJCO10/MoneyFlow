import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';

class AllTransactionsController extends GetxController {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();
  
  var isLoading = false.obs;
  var allTransactions = <Transaction>[].obs;
  var filteredTransactions = <Transaction>[].obs;
  var allCategories = <Category>[].obs;
  var filteredCategories = <Category>[].obs; // <-- Categorías filtradas por tipo
  
  // Filtros
  var selectedType = 'all'.obs; // 'all', 'income', 'expense'
  var selectedCategoryId = 0.obs; // 0 = todas
  var searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Cargar todas las categorías
      allCategories.value = await _categoryService.getAllCategories();
      
      // Actualizar categorías filtradas según el tipo seleccionado
      _updateFilteredCategories();
      
      // Cargar todas las transacciones
      allTransactions.value = await _transactionService.getAllTransactions();
      
      // Aplicar filtros
      applyFilters();
      
    } catch (e) {
      print('❌ Error cargando transacciones: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _updateFilteredCategories() {
    if (selectedType.value == 'all') {
      // Mostrar todas las categorías
      filteredCategories.value = allCategories.toList();
    } else {
      // Mostrar solo categorías del tipo seleccionado
      filteredCategories.value = allCategories
          .where((c) => c.type == selectedType.value)
          .toList();
    }
    
    // Si la categoría seleccionada no está en la lista filtrada, resetear
    if (selectedCategoryId.value != 0) {
      final exists = filteredCategories.any((c) => c.id == selectedCategoryId.value);
      if (!exists) {
        selectedCategoryId.value = 0;
      }
    }
  }
  
  void applyFilters() {
    var result = allTransactions.toList();
    
    // Filtrar por tipo
    if (selectedType.value != 'all') {
      result = result.where((t) => t.type == selectedType.value).toList();
    }
    
    // Filtrar por categoría
    if (selectedCategoryId.value != 0) {
      result = result.where((t) => t.categoryId == selectedCategoryId.value).toList();
    }
    
    // Filtrar por búsqueda
    if (searchQuery.value.isNotEmpty) {
      result = result.where((t) => 
        t.description.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    // Ordenar por fecha (más reciente primero)
    result.sort((a, b) => b.date.compareTo(a.date));
    
    filteredTransactions.value = result;
  }
  
  void filterByType(String type) {
    selectedType.value = type;
    _updateFilteredCategories(); // <-- Actualizar categorías disponibles
    applyFilters();
  }
  
  void filterByCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
    applyFilters();
  }
  
  void search(String query) {
    searchQuery.value = query;
    applyFilters();
  }
  
  void clearFilters() {
    selectedType.value = 'all';
    selectedCategoryId.value = 0;
    searchQuery.value = '';
    _updateFilteredCategories();
    applyFilters();
  }
  
  String getCategoryName(int categoryId) {
    for (var cat in allCategories) {
      if (cat.id == categoryId) {
        return cat.name;
      }
    }
    return 'Sin categoría';
  }
  
  String getCategoryIcon(int categoryId) {
    for (var cat in allCategories) {
      if (cat.id == categoryId) {
        return cat.icon;
      }
    }
    return '📌';
  }
  
  double getTotalIncome() {
    return filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  double getTotalExpense() {
    return filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }
  
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  Future<void> deleteTransaction(int id) async {
    try {
      await _transactionService.deleteTransaction(id);
      await loadData();
      
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
}
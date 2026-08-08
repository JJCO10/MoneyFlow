import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';

class EditTransactionController extends GetxController {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();
  
  // La transacción a editar
  final Transaction transaction;
  
  // Observables
  var isLoading = false.obs;
  var selectedType = 'expense'.obs;
  var selectedCategoryId = 0.obs;
  var selectedDate = DateTime.now().obs;
  var amount = 0.0.obs;
  var categories = <Category>[].obs;
  
  // Controladores de texto
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  
  EditTransactionController(this.transaction);
  
  @override
  void onInit() {
    super.onInit();
    // Cargar datos de la transacción
    selectedType.value = transaction.type;
    selectedDate.value = transaction.date;
    amount.value = transaction.amount;
    amountController.text = transaction.amount.toString();
    descriptionController.text = transaction.description;
    
    loadCategories();
  }
  
  Future<void> loadCategories() async {
    try {
      categories.value = await _categoryService.getCategoriesByType(selectedType.value);
      // Seleccionar la categoría de la transacción
      if (categories.any((c) => c.id == transaction.categoryId)) {
        selectedCategoryId.value = transaction.categoryId;
      } else if (categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id!;
      }
    } catch (e) {
      print('❌ Error cargando categorías: $e');
    }
  }
  
  void updateCategories(String type) {
    selectedType.value = type;
    loadCategories();
  }
  
  Future<void> updateTransaction() async {
    if (!_validateForm()) return;
    
    isLoading.value = true;
    
    try {
      final updatedTransaction = Transaction(
        id: transaction.id,
        amount: amount.value,
        type: selectedType.value,
        categoryId: selectedCategoryId.value,
        description: descriptionController.text,
        date: selectedDate.value,
        isRecurring: transaction.isRecurring,
      );
      
      await _transactionService.updateTransaction(updatedTransaction);
      
      Get.back(result: true);
      
      Get.snackbar(
        'Éxito',
        'Transacción actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la transacción: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  bool _validateForm() {
    if (amount.value <= 0) {
      Get.snackbar(
        'Error',
        'El monto debe ser mayor a 0',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    
    if (descriptionController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'La descripción es requerida',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    
    if (selectedCategoryId.value == 0) {
      Get.snackbar(
        'Error',
        'Selecciona una categoría',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    
    return true;
  }
  
  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
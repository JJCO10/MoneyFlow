import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();
  
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
  
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }
  
  Future<void> loadCategories() async {
    try {
      categories.value = await _categoryService.getCategoriesByType(selectedType.value);
      if (categories.isNotEmpty) {
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
  
  Future<void> saveTransaction() async {
    if (!_validateForm()) return;
    
    isLoading.value = true;
    
    try {
      final transaction = Transaction(
        amount: amount.value,
        type: selectedType.value,
        categoryId: selectedCategoryId.value,
        description: descriptionController.text,
        date: selectedDate.value,
        isRecurring: false,
      );
      
      await _transactionService.saveTransaction(transaction);
      
      // Limpiar formulario
      amountController.clear();
      descriptionController.clear();
      amount.value = 0;
      selectedCategoryId.value = categories.first.id!;
      
      Get.back(result: true);
      
      Get.snackbar(
        'Éxito',
        'Transacción guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar la transacción: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
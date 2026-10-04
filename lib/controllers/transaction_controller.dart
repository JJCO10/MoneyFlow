import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/l10n/translations.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();

  // Observables existentes
  var isLoading = false.obs;
  var selectedType = 'expense'.obs;
  var selectedCategoryId = 0.obs;
  var selectedDate = DateTime.now().obs;
  var amount = 0.0.obs;
  var categories = <Category>[].obs;

  // 🔥 NUEVOS OBSERVABLES PARA RECURRENCIA
  var isRecurring = false.obs;
  var recurrenceType = 'monthly'.obs; // 'daily', 'weekly', 'monthly', 'yearly'
  var recurrenceEnd = DateTime.now().add(const Duration(days: 365)).obs;
  var hasRecurrenceEnd = false.obs; // Si el usuario quiere fecha de fin

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
      categories.value =
          await _categoryService.getCategoriesByType(selectedType.value);
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

  // 🔥 ACTUALIZAR TIPO DE RECURRENCIA
  void updateRecurrenceType(String type) {
    recurrenceType.value = type;
  }

  // 🔥 ACTIVAR/DESACTIVAR RECURRENCIA
  void toggleRecurring(bool value) {
    isRecurring.value = value;
  }

  // 🔥 ACTIVAR/DESACTIVAR FECHA DE FIN
  void toggleRecurrenceEnd(bool value) {
    hasRecurrenceEnd.value = value;
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
        isRecurring: isRecurring.value,
        // 🔥 CAMPOS DE RECURRENCIA
        recurrenceType: isRecurring.value ? recurrenceType.value : null,
        recurrenceEnd: isRecurring.value && hasRecurrenceEnd.value
            ? recurrenceEnd.value
            : null,
      );

      await _transactionService.saveTransaction(transaction);

      // Limpiar formulario
      _resetForm();

      // Cerrar pantalla con resultado true (éxito)
      Get.back(result: true);

      // 🔥 MENSAJE SEGÚN SI ES RECURRENTE
      final message = isRecurring.value
          ? 'Transacción recurrente guardada correctamente'
          : 'Transacción guardada correctamente';

      Get.snackbar(
        'success'.t,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'error'.t,
        'No se pudo guardar la transacción: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 RESET DEL FORMULARIO
  void _resetForm() {
    amountController.clear();
    descriptionController.clear();
    amount.value = 0;
    isRecurring.value = false;
    recurrenceType.value = 'monthly';
    hasRecurrenceEnd.value = false;
    if (categories.isNotEmpty) {
      selectedCategoryId.value = categories.first.id!;
    }
  }

  bool _validateForm() {
    if (amount.value <= 0) {
      Get.snackbar(
        'error'.t,
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
        'error'.t,
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
        'error'.t,
        'Selecciona una categoría',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    // 🔥 VALIDAR FECHA DE FIN SI APLICA
    if (isRecurring.value && hasRecurrenceEnd.value) {
      if (recurrenceEnd.value.isBefore(selectedDate.value)) {
        Get.snackbar(
          'error'.t,
          'La fecha de fin debe ser posterior a la fecha de inicio',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return false;
      }
    }

    return true;
  }

  // 🔥 OBTENER ETIQUETA DE RECURRENCIA
  String getRecurrenceLabel(String type) {
    switch (type) {
      case 'daily':
        return 'daily'.t;
      case 'weekly':
        return 'weekly'.t;
      case 'monthly':
        return 'monthly'.t;
      case 'yearly':
        return 'yearly'.t;
      default:
        return 'monthly'.t;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

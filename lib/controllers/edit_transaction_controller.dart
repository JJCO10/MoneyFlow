import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/l10n/translations.dart';

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
      categories.value =
          await _categoryService.getCategoriesByType(selectedType.value);
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
        // 🔥 MANTENER CAMPOS DE RECURRENCIA
        recurrenceType: transaction.recurrenceType,
        recurrenceEnd: transaction.recurrenceEnd,
        parentId: transaction.parentId,
      );

      await _transactionService.updateTransaction(updatedTransaction);

      Get.back(result: true);

      Get.snackbar(
        'success'.t,
        'transaction_updated'.t,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'error'.t,
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

  // 🔥 ELIMINAR SEGÚN EL TIPO DE TRANSACCIÓN
  Future<void> deleteTransaction() async {
    // 🔥 CASO 1: ES UNA TRANSACCIÓN HIJA (generada por recurrencia)
    if (transaction.parentId != null) {
      final result = await Get.dialog<String>(
        AlertDialog(
          title: Text('delete'.t),
          content: Text('generated_transaction_message'.t),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: 'cancel'),
              child: Text('cancel'.t),
            ),
            TextButton(
              onPressed: () => Get.back(result: 'single'),
              child: Text('delete_only_this'.t),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: 'all'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('delete_all_recurrence'.t),
            ),
          ],
        ),
      );

      if (result == 'cancel' || result == null) return;

      isLoading.value = true;

      try {
        if (result == 'single') {
          // Eliminar solo esta hija
          await _transactionService.deleteTransaction(transaction.id!);
          print('✅ Transacción hija eliminada');
        } else if (result == 'all') {
          // Eliminar toda la recurrencia (padre + hijas)
          await _transactionService
              .deleteParentWithChildren(transaction.parentId!);
          print('✅ Recurrencia completa eliminada');
        }

        Get.back(result: true);

        Get.snackbar(
          'success'.t,
          'transaction_deleted'.t,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        Get.snackbar(
          'error'.t,
          'No se pudo eliminar la transacción: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } finally {
        isLoading.value = false;
      }

      return;
    }

    // 🔥 CASO 2: ES UNA TRANSACCIÓN PADRE RECURRENTE
    if (transaction.isRecurring && transaction.parentId == null) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text('delete'.t),
          content: Text('delete_recurring_transaction'.t),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.t),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('delete'.t),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      isLoading.value = true;

      try {
        await _transactionService.deleteTransaction(transaction.id!);

        Get.back(result: true);

        Get.snackbar(
          'success'.t,
          'transaction_deleted'.t,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        Get.snackbar(
          'error'.t,
          'No se pudo eliminar la transacción: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } finally {
        isLoading.value = false;
      }

      return;
    }

    // 🔥 CASO 3: TRANSACCIÓN NORMAL
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('delete'.t),
        content: Text('confirm_delete_transaction'.t),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.t),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('delete'.t),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;

    try {
      await _transactionService.deleteTransaction(transaction.id!);

      Get.back(result: true);

      Get.snackbar(
        'success'.t,
        'transaction_deleted'.t,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'error'.t,
        'No se pudo eliminar la transacción: $e',
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

    return true;
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

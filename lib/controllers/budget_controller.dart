import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/budget_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/services/notification_service.dart';
import 'package:money_flow/models/budget_model.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/theme/colors.dart';

class BudgetController extends GetxController {
  final BudgetService _budgetService = Get.find();
  final CategoryService _categoryService = Get.find();
  final NotificationService _notificationService = Get.find();

  var isLoading = false.obs;
  var budgets = <Map<String, dynamic>>[].obs;
  var categories = <Category>[].obs;

  final Set<int> _notifiedCategories = {};

  @override
  void onInit() {
    super.onInit();
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      isLoading.value = true;

      categories.value = await _categoryService.getCategoriesByType('expense');

      final budgetList = await _budgetService.getAllBudgets();

      final result = <Map<String, dynamic>>[];

      for (var category in categories) {
        Budget? budget;
        for (var b in budgetList) {
          if (b.categoryId == category.id) {
            budget = b;
            break;
          }
        }

        final spent = await _budgetService.getCategorySpending(category.id!);
        final progress = budget != null ? (spent / budget.limit) * 100 : 0.0;

        // 🔥 VERIFICAR ALERTA DE PRESUPUESTO
        if (budget != null) {
          final isOverBudget = spent > budget.limit;
          final isNearLimit = spent >= budget.limit * 0.8 && spent <= budget.limit;
          final categoryId = category.id!;

          if ((isNearLimit || isOverBudget) && !_notifiedCategories.contains(categoryId)) {
            _notifiedCategories.add(categoryId);

            final percentage = (spent / budget.limit * 100).toStringAsFixed(0);
            final remaining = (budget.limit - spent).toStringAsFixed(2);
            final overAmount = spent - budget.limit; // 🔥 CORREGIDO

            String title = isOverBudget
                ? '⚠️ Presupuesto Excedido'
                : '⚠️ Alerta de Presupuesto';
            String body = isOverBudget
                ? 'Has excedido el presupuesto de ${category.name}. Excedido: \$${overAmount.toStringAsFixed(2)}'
                : 'Has gastado el $percentage% del presupuesto de ${category.name}. Restante: \$${remaining}';

            await _notificationService.showNotification(
              id: categoryId,
              title: title,
              body: body,
              payload: 'budgets',
            );
          }
        }

        result.add({
          'category': category,
          'budget': budget,
          'spent': spent,
          'progress': progress.clamp(0.0, 100.0),
          'remaining': budget != null ? (budget.limit - spent) : 0.0,
          'isOverBudget': budget != null && spent > budget.limit,
        });
      }

      budgets.value = result;

    } catch (e) {
      print('❌ Error cargando presupuestos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void resetNotifications() {
    _notifiedCategories.clear();
  }

  Future<void> saveBudget(int categoryId, double limit, String period) async {
    try {
      final budget = Budget(
        categoryId: categoryId,
        limit: limit,
        period: period,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _budgetService.saveBudget(budget);
      await loadBudgets();

      Get.snackbar(
        'Éxito',
        'Presupuesto guardado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el presupuesto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> deleteBudget(int budgetId) async {
    try {
      await _budgetService.deleteBudget(budgetId);
      await loadBudgets();

      Get.snackbar(
        'Éxito',
        'Presupuesto eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el presupuesto',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void showAddBudgetDialog(BuildContext context, {int? categoryId}) {
    final selectedCategoryId = categoryId?.obs ?? 0.obs;
    final limit = 0.0.obs;
    final period = 'monthly'.obs;

    final limitController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          categoryId != null ? 'Establecer Presupuesto' : 'Nuevo Presupuesto',
          style: TextStyle(color: textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => DropdownButtonFormField<int>(
                value: selectedCategoryId.value == 0 ? null : selectedCategoryId.value,
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(color: textSecondary),
                  border: const OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(
                      '${category.icon} ${category.name}',
                      style: TextStyle(color: textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategoryId.value = value;
                  }
                },
              )),
              const SizedBox(height: 16),
              TextField(
                controller: limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Límite',
                  labelStyle: TextStyle(color: textSecondary),
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  limit.value = double.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                value: period.value,
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Período',
                  labelStyle: TextStyle(color: textSecondary),
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                  DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    period.value = value;
                  }
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedCategoryId.value == 0) {
                Get.snackbar('Error', 'Selecciona una categoría');
                return;
              }
              if (limit.value <= 0) {
                Get.snackbar('Error', 'El límite debe ser mayor a 0');
                return;
              }

              saveBudget(selectedCategoryId.value, limit.value, period.value);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
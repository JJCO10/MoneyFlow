import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/transaction_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:money_flow/l10n/translations.dart';

class AddTransactionScreen extends StatelessWidget {
  AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fillColor = isDark ? AppColors.darkSurface : Colors.grey[50];

    return Scaffold(
      appBar: AppBar(
        title: Text('add_transaction_title'.t),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: false),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(controller, isDark),
              const SizedBox(height: 24),
              _buildAmountField(controller, isDark, fillColor),
              const SizedBox(height: 16),
              _buildDescriptionField(controller, isDark, fillColor),
              const SizedBox(height: 16),
              _buildCategorySelector(controller, isDark, fillColor),
              const SizedBox(height: 16),
              _buildDatePicker(controller, isDark),
              const SizedBox(height: 16),
              // 🔥 SECCIÓN DE RECURRENCIA
              _buildRecurrenceSection(
                  controller, isDark, fillColor, textPrimary, textSecondary),
              const SizedBox(height: 32),
              _buildSaveButton(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTypeSelector(TransactionController controller, bool isDark) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                'expense_type'.t,
                'expense',
                Icons.arrow_downward,
                AppColors.danger,
                controller.selectedType.value == 'expense',
                () => controller.updateCategories('expense'),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                'income_type'.t,
                'income',
                Icons.arrow_upward,
                AppColors.secondary,
                controller.selectedType.value == 'income',
                () => controller.updateCategories('income'),
                isDark,
              ),
            ),
          ],
        ));
  }

  Widget _buildTypeCard(
    String label,
    String type,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    final bgColor = isDark ? AppColors.darkSurface : Colors.grey[50];
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[200];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : borderColor!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : (isDark ? Colors.grey[500] : Colors.grey[400]),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(
      TransactionController controller, bool isDark, Color? fillColor) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return TextField(
      controller: controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: 'amount'.t,
        labelStyle: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
        prefixIcon: Icon(Icons.attach_money,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
        prefixText: '\$ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: fillColor,
      ),
      onChanged: (value) {
        controller.amount.value = double.tryParse(value) ?? 0;
      },
    );
  }

  Widget _buildDescriptionField(
      TransactionController controller, bool isDark, Color? fillColor) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return TextField(
      controller: controller.descriptionController,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: 'description'.t,
        labelStyle: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
        hintText: 'Ej: Almuerzo, Supermercado, etc.',
        hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextLight : AppColors.lightTextLight),
        prefixIcon: Icon(Icons.description,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: fillColor,
      ),
      maxLines: 2,
    );
  }

  Widget _buildCategorySelector(
      TransactionController controller, bool isDark, Color? fillColor) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'no_categories'.t,
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
          ),
        );
      }

      return DropdownButtonFormField<int>(
        value: controller.selectedCategoryId.value,
        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: 'category'.t,
          labelStyle: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
          prefixIcon: Icon(Icons.category,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: fillColor,
        ),
        items: controller.categories.map((category) {
          return DropdownMenuItem<int>(
            value: category.id,
            child: Row(
              children: [
                Text(
                  category.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.selectedCategoryId.value = value;
          }
        },
      );
    });
  }

  Widget _buildDatePicker(TransactionController controller, bool isDark) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Obx(() => ListTile(
          leading: Icon(Icons.calendar_today,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
          title: Text(
            'date'.t,
            style: TextStyle(color: textColor),
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy').format(controller.selectedDate.value),
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 16,
              color:
                  isDark ? AppColors.darkTextLight : AppColors.lightTextLight),
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              controller.selectedDate.value = date;
            }
          },
        ));
  }

  // 🔥 SECCIÓN DE RECURRENCIA
  Widget _buildRecurrenceSection(
    TransactionController controller,
    bool isDark,
    Color? fillColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 SWITCH DE RECURRENCIA
          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'recurring_transaction'.t,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'recurring_transaction_subtitle'.t,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                value: controller.isRecurring.value,
                onChanged: (value) => controller.toggleRecurring(value),
                activeColor: AppColors.primary,
              )),

          // 🔥 OPCIONES DE RECURRENCIA (si está activado)
          Obx(() {
            if (!controller.isRecurring.value) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),

                // Tipo de recurrencia
                Text(
                  'recurrence_frequency'.t,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRecurrenceTypeSelector(controller, isDark),

                const SizedBox(height: 16),

                // Fecha de fin
                Obx(() => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'has_end_date'.t,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      value: controller.hasRecurrenceEnd.value,
                      onChanged: (value) =>
                          controller.toggleRecurrenceEnd(value),
                      activeColor: AppColors.primary,
                    )),

                // Selector de fecha de fin
                Obx(() {
                  if (!controller.hasRecurrenceEnd.value) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.event,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    title: Text(
                      'end_date'.t,
                      style: TextStyle(color: textPrimary),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy')
                          .format(controller.recurrenceEnd.value),
                      style: TextStyle(color: textSecondary),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextLight
                          : AppColors.lightTextLight,
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: Get.context!,
                        initialDate: controller.recurrenceEnd.value,
                        firstDate: controller.selectedDate.value,
                        lastDate: DateTime(2050),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        controller.recurrenceEnd.value = date;
                      }
                    },
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  // 🔥 SELECTOR DE TIPO DE RECURRENCIA
  Widget _buildRecurrenceTypeSelector(
      TransactionController controller, bool isDark) {
    final frequencies = [
      {'value': 'daily', 'label': 'daily'.t, 'icon': Icons.today},
      {'value': 'weekly', 'label': 'weekly'.t, 'icon': Icons.date_range},
      {'value': 'monthly', 'label': 'monthly'.t, 'icon': Icons.calendar_month},
      {'value': 'yearly', 'label': 'yearly'.t, 'icon': Icons.calendar_today},
    ];

    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: frequencies.map((freq) {
            final isSelected = controller.recurrenceType.value == freq['value'];

            return GestureDetector(
              onTap: () =>
                  controller.updateRecurrenceType(freq['value'] as String),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : (isDark ? Colors.grey[800] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      freq['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      freq['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildSaveButton(TransactionController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
                controller.isLoading.value ? null : controller.saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'save'.t,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
  }
}

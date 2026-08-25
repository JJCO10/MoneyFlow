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
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
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
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
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
              color: isSelected ? color : (isDark ? Colors.grey[500] : Colors.grey[400]),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAmountField(TransactionController controller, bool isDark, Color? fillColor) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    
    return TextField(
      controller: controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: 'amount'.t,
        labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        prefixIcon: Icon(Icons.attach_money, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
  
  Widget _buildDescriptionField(TransactionController controller, bool isDark, Color? fillColor) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    
    return TextField(
      controller: controller.descriptionController,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: 'description'.t,
        labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        hintText: 'Ej: Almuerzo, Supermercado, etc.',
        hintStyle: TextStyle(color: isDark ? AppColors.darkTextLight : AppColors.lightTextLight),
        prefixIcon: Icon(Icons.description, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: fillColor,
      ),
      maxLines: 2,
    );
  }
  
  Widget _buildCategorySelector(TransactionController controller, bool isDark, Color? fillColor) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'no_categories'.t,
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
          labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          prefixIcon: Icon(Icons.category, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return Obx(() => ListTile(
      leading: Icon(Icons.calendar_today, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? AppColors.darkTextLight : AppColors.lightTextLight),
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
  
  Widget _buildSaveButton(TransactionController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveTransaction,
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
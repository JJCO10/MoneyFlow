import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/transaction_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatelessWidget {
  AddTransactionScreen({super.key}); // SIN const

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Transacción'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: false), // <-- Enviar false al cancelar
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
              // Selector de tipo (Ingreso/Gasto)
              _buildTypeSelector(controller),
              const SizedBox(height: 24),
              
              // Campo de monto
              _buildAmountField(controller),
              const SizedBox(height: 16),
              
              // Campo de descripción
              _buildDescriptionField(controller),
              const SizedBox(height: 16),
              
              // Selector de categoría
              _buildCategorySelector(controller),
              const SizedBox(height: 16),
              
              // Selector de fecha
              _buildDatePicker(controller),
              const SizedBox(height: 32),
              
              // Botón guardar
              _buildSaveButton(controller),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildTypeSelector(TransactionController controller) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildTypeCard(
            'Gasto',
            'expense',
            Icons.arrow_downward,
            AppColors.danger,
            controller.selectedType.value == 'expense',
            () => controller.updateCategories('expense'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeCard(
            'Ingreso',
            'income',
            Icons.arrow_upward,
            AppColors.secondary,
            controller.selectedType.value == 'income',
            () => controller.updateCategories('income'),
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
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[400],
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAmountField(TransactionController controller) {
    return TextField(
      controller: controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Monto',
        prefixIcon: const Icon(Icons.attach_money),
        prefixText: '\$ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onChanged: (value) {
        controller.amount.value = double.tryParse(value) ?? 0;
      },
    );
  }
  
  Widget _buildDescriptionField(TransactionController controller) {
    return TextField(
      controller: controller.descriptionController,
      decoration: InputDecoration(
        labelText: 'Descripción',
        hintText: 'Ej: Almuerzo, Supermercado, etc.',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 2,
    );
  }
  
  Widget _buildCategorySelector(TransactionController controller) {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('No hay categorías disponibles'),
          ),
        );
      }
      
      return DropdownButtonFormField<int>(
        value: controller.selectedCategoryId.value,
        decoration: InputDecoration(
          labelText: 'Categoría',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
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
                Text(category.name),
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
  
  Widget _buildDatePicker(TransactionController controller) {
    return Obx(() => ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Fecha'),
      subtitle: Text(
        DateFormat('dd/MM/yyyy').format(controller.selectedDate.value),
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
            : const Text(
                'Guardar Transacción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    ));
  }
}
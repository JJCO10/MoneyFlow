import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/transaction_controller.dart';
import 'package:money_flow/theme/app_theme.dart';
import 'package:money_flow/theme/colors.dart';

class AddTransactionScreen extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Transacción'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selector de tipo
            _buildTypeSelector(),
            const SizedBox(height: 16),
            
            // Categoría
            _buildCategorySelector(),
            const SizedBox(height: 16),
            
            // Monto
            _buildAmountField(),
            const SizedBox(height: 16),
            
            // Descripción
            _buildDescriptionField(),
            const SizedBox(height: 16),
            
            // Fecha
            _buildDatePicker(),
            const SizedBox(height: 24),
            
            // Botón de guardar
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeSelector() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildTypeCard('Ingreso', 'income', Icons.arrow_upward, AppColors.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeCard('Gasto', 'expense', Icons.arrow_downward, AppColors.danger),
        ),
      ],
    ));
  }
  
  Widget _buildTypeCard(String label, String type, IconData icon, Color color) {
    final isSelected = controller.selectedType.value == type;
    return GestureDetector(
      onTap: () => controller.selectedType.value = type,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategorySelector() {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return const CircularProgressIndicator();
      }
      
      return DropdownButtonFormField<int>(
        value: controller.selectedCategoryId.value,
        decoration: const InputDecoration(
          labelText: 'Categoría',
          prefixIcon: Icon(Icons.category),
        ),
        items: controller.categories.map((category) {
          return DropdownMenuItem<int>(
            value: category.id,
            child: Row(
              children: [
                Icon(Icons.category, size: 16),
                const SizedBox(width: 8),
                Text(category.name),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => controller.selectedCategoryId.value = value!,
      );
    });
  }
  
  Widget _buildAmountField() {
    return TextField(
      controller: controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Monto',
        prefixIcon: Icon(Icons.attach_money),
        prefixText: '\$ ',
      ),
      onChanged: (value) => controller.amount.value = double.tryParse(value) ?? 0,
    );
  }
  
  Widget _buildDescriptionField() {
    return TextField(
      controller: controller.descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descripción',
        prefixIcon: Icon(Icons.description),
      ),
    );
  }
  
  Widget _buildDatePicker() {
    return Obx(() => ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Fecha'),
      subtitle: Text(
        '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        final date = await showDatePicker(
          context: Get.context!,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          controller.selectedDate.value = date;
        }
      },
    ));
  }
  
  Widget _buildSaveButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : () => controller.saveTransaction(),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: controller.isLoading.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Text('Guardar Transacción'),
    ));
  }
}
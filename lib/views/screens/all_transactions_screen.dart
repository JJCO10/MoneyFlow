import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/all_transactions_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/transaction_card.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllTransactionsController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas las Transacciones'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            // Buscador
            _buildSearchBar(controller),
            
            // Resumen
            _buildSummary(controller),
            
            // Lista de transacciones
            Expanded(
              child: _buildTransactionList(controller),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildSearchBar(AllTransactionsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar transacciones...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () {
                  controller.searchQuery.value = '';
                  controller.applyFilters();
                },
              );
            }
            return const SizedBox();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) => controller.search(value),
      ),
    );
  }
  
  Widget _buildSummary(AllTransactionsController controller) {
    final income = controller.getTotalIncome();
    final expense = controller.getTotalExpense();
    final balance = controller.getBalance();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryChip(
              'Ingresos',
              '\$${income.toStringAsFixed(2)}',
              AppColors.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryChip(
              'Gastos',
              '\$${expense.toStringAsFixed(2)}',
              AppColors.danger,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryChip(
              'Balance',
              '\$${balance.toStringAsFixed(2)}',
              balance >= 0 ? AppColors.primary : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryChip(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionList(AllTransactionsController controller) {
    if (controller.filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay transacciones',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            if (controller.searchQuery.value.isNotEmpty ||
                controller.selectedType.value != 'all' ||
                controller.selectedCategoryId.value != 0)
              TextButton(
                onPressed: () => controller.clearFilters(),
                child: const Text('Limpiar filtros'),
              ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.filteredTransactions[index];
        return TransactionCard(
          transaction: transaction,
          categoryName: controller.getCategoryName(transaction.categoryId),
          categoryIcon: controller.getCategoryIcon(transaction.categoryId),
          onTap: () {
            // TODO: Editar transacción
            Get.snackbar('Info', 'Editar en desarrollo');
          },
          onDelete: () => controller.deleteTransaction(transaction.id!),
        );
      },
    );
  }
  
  void _showFilterDialog(BuildContext context, AllTransactionsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // <-- PERMITIR SCROLL
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filtro por tipo
                  const Text(
                    'Tipo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Row(
                    children: [
                      _buildFilterChip(
                        'Todos',
                        'all',
                        controller.selectedType.value,
                        () => controller.filterByType('all'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Ingresos',
                        'income',
                        controller.selectedType.value,
                        () => controller.filterByType('income'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Gastos',
                        'expense',
                        controller.selectedType.value,
                        () => controller.filterByType('expense'),
                      ),
                    ],
                  )),
                  const SizedBox(height: 16),
                  
                  // Filtro por categoría (con scroll)
                  const Text(
                    'Categoría',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Obx(() {
                      if (controller.filteredCategories.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay categorías para este tipo',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildCategoryChip(
                              'Todas',
                              0,
                              controller.selectedCategoryId.value,
                              () => controller.filterByCategory(0),
                            ),
                            ...controller.filteredCategories.map((category) {
                              // Truncar nombres largos para evitar desbordamiento
                              String displayName = category.name;
                              if (displayName.length > 12) {
                                displayName = '${displayName.substring(0, 12)}...';
                              }
                              return _buildCategoryChip(
                                '${category.icon} $displayName',
                                category.id!,
                                controller.selectedCategoryId.value,
                                () => controller.filterByCategory(category.id!),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón limpiar filtros
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Limpiar filtros'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFilterChip(String label, String value, String selected, VoidCallback onTap) {
    final isSelected = selected == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
    );
  }
  
  Widget _buildCategoryChip(String label, int value, int selected, VoidCallback onTap) {
    final isSelected = selected == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis, // <-- Prevenir desbordamiento
        maxLines: 1,
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // <-- Padding reducido
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // <-- Más redondeado
      ),
    );
  }
}
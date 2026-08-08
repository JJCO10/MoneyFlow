import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/all_transactions_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/transaction_card.dart';
import 'package:money_flow/views/screens/edit_transaction_screen.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllTransactionsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
            _buildSearchBar(controller, isDark),
            
            // Resumen
            _buildSummary(controller, isDark),
            
            // Lista de transacciones
            Expanded(
              child: _buildTransactionList(controller),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildSearchBar(AllTransactionsController controller, bool isDark) {
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fillColor = isDark ? AppColors.darkSurface : Colors.grey[100];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar transacciones...',
          hintStyle: TextStyle(color: textColor),
          prefixIcon: Icon(Icons.search, color: textColor),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: Icon(Icons.clear, color: textColor),
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
          fillColor: fillColor,
        ),
        onChanged: (value) => controller.search(value),
      ),
    );
  }
  
  Widget _buildSummary(AllTransactionsController controller, bool isDark) {
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
              isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryChip(
              'Gastos',
              '\$${expense.toStringAsFixed(2)}',
              AppColors.danger,
              isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryChip(
              'Balance',
              '\$${balance.toStringAsFixed(2)}',
              balance >= 0 ? AppColors.primary : AppColors.danger,
              isDark,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryChip(String label, String amount, Color color, bool isDark) {
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
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
              color: textColor,
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
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final iconColor = isDark ? Colors.grey[600] : Colors.grey[300];
    
    if (controller.filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              'No hay transacciones',
              style: TextStyle(
                color: textColor,
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
          onTap: () async {
            final result = await Get.to(() => EditTransactionScreen(
              transaction: transaction,
            ));
            if (result == true) {
              controller.loadData();
            }
          },
          onDelete: () => controller.deleteTransaction(transaction.id!),
        );
      },
    );
  }
  
  void _showFilterDialog(BuildContext context, AllTransactionsController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final chipBgColor = isDark ? Colors.grey[700] : Colors.grey[200];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filtro por tipo
                  Text(
                    'Tipo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
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
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Ingresos',
                        'income',
                        controller.selectedType.value,
                        () => controller.filterByType('income'),
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Gastos',
                        'expense',
                        controller.selectedType.value,
                        () => controller.filterByType('expense'),
                        isDark,
                      ),
                    ],
                  )),
                  const SizedBox(height: 16),
                  
                  // Filtro por categoría
                  Text(
                    'Categoría',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Obx(() {
                      if (controller.filteredCategories.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay categorías para este tipo',
                            style: TextStyle(color: textSecondary),
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
                              isDark,
                            ),
                            ...controller.filteredCategories.map((category) {
                              String displayName = category.name;
                              if (displayName.length > 12) {
                                displayName = '${displayName.substring(0, 12)}...';
                              }
                              return _buildCategoryChip(
                                '${category.icon} $displayName',
                                category.id!,
                                controller.selectedCategoryId.value,
                                () => controller.filterByCategory(category.id!),
                                isDark,
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
  
  Widget _buildFilterChip(String label, String value, String selected, VoidCallback onTap, bool isDark) {
    final isSelected = selected == value;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final chipBgColor = isDark ? Colors.grey[700] : Colors.grey[200];
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : textColor,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: chipBgColor,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
    );
  }
  
  Widget _buildCategoryChip(String label, int value, int selected, VoidCallback onTap, bool isDark) {
    final isSelected = selected == value;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final chipBgColor = isDark ? Colors.grey[700] : Colors.grey[200];
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : textColor,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: chipBgColor,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
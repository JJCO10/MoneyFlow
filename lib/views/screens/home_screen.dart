import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/home_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/screens/all_transactions_screen.dart';
import 'package:money_flow/views/screens/budgets_screen.dart';
import 'package:money_flow/views/screens/calendar_screen.dart';
import 'package:money_flow/views/screens/charts_screen.dart';
import 'package:money_flow/views/screens/edit_transaction_screen.dart';
import 'package:money_flow/views/screens/settings_screen.dart';
import 'package:money_flow/views/widgets/transaction_card.dart';
import 'package:money_flow/views/screens/add_transaction_screen.dart';
import 'package:money_flow/views/screens/categories_screen.dart';
import 'package:money_flow/l10n/translations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final selectedIndex = 0.obs;
    
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        actions: [],
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          // ==================== CONTENIDO PRINCIPAL ====================
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return RefreshIndicator(
              onRefresh: controller.loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16).copyWith(
                  bottom: 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'app_name'.t,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBalanceSummary(controller, isDark),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(controller, isDark),
                  ],
                ),
              ),
            );
          }),
          
          // ==================== BOTÓN DE SETTINGS (ARRIBA DERECHA) ====================
          Positioned(
            top: 4,
            right: 12,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  color: AppColors.primary,
                  onPressed: () => Get.to(() => const SettingsScreen()),
                  iconSize: 24,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ),
          
          // ==================== BOTÓN DE AGREGAR (DERECHA) ====================
          Positioned(
            bottom: 20,  // 🔥 Ajusta este valor (70-90)
            right: 24,   // 🔥 Posición desde la derecha
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Get.to(() => AddTransactionScreen());
                  if (result == true) {
                    await controller.loadData();
                    Get.snackbar(
                      'info'.t,
                      'data_updated'.t,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1),
                    );
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
      // ==================== BOTTOM NAVIGATION BAR ====================
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: selectedIndex.value,
        onTap: (index) {
          selectedIndex.value = index;
          switch (index) {
            case 0:
              break;
            case 1:
              Get.to(() => const CalendarScreen());
              break;
            case 2:
              Get.to(() => const ChartsScreen());
              break;
            case 3:
              Get.to(() => const CategoriesScreen());
              break;
            case 4:
              Get.to(() => const BudgetsScreen());
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home_title'.t,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: 'calendar_title'.t,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: 'charts_title'.t,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: 'categories_title'.t,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: 'budgets_title'.t,
          ),
        ],
      )),
    );
  }
  
  Widget _buildBalanceSummary(HomeController controller, bool isDark) {
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'income'.t,
            '\$${controller.totalIncome.value.toStringAsFixed(2)}',
            AppColors.secondary,
            Icons.arrow_upward,
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'expense'.t,
            '\$${controller.totalExpense.value.toStringAsFixed(2)}',
            AppColors.danger,
            Icons.arrow_downward,
            textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'balance'.t,
            '\$${controller.balance.value.toStringAsFixed(2)}',
            controller.balance.value >= 0 ? AppColors.primary : AppColors.danger,
            Icons.account_balance,
            textColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentTransactions(HomeController controller, bool isDark) {
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textLight = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    
    if (controller.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: isDark ? Colors.grey[600] : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'no_transactions_message'.t,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'add_transaction_message'.t,
                style: TextStyle(
                  color: textLight,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'recent_transactions'.t,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const AllTransactionsScreen()),
              child: Text('view_all'.t),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...controller.transactions.take(10).map((transaction) {
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
        }).toList(),
      ],
    );
  }
}
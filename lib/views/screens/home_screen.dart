import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/home_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/screens/all_transactions_screen.dart';
import 'package:money_flow/views/screens/edit_transaction_screen.dart';
import 'package:money_flow/views/screens/settings_screen.dart';
import 'package:money_flow/views/widgets/transaction_card.dart';
import 'package:money_flow/l10n/translations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
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
                  onPressed: () {
                    // 🔥 ELIMINAR Get.find<HapticFeedbackService>().lightVibrate();
                    Get.to(() => const SettingsScreen());
                  },
                  iconSize: 24,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ),
        ],
      ),
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
    
    final transactionList = controller.transactions.take(10).toList();
    
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
        ...transactionList.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index / transactionList.length, 
                  1.0, 
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: TransactionCard(
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
            ),
          );
        }).toList(),
      ],
    );
  }
}
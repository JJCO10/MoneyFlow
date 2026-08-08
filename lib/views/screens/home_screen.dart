import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/home_controller.dart';
import 'package:money_flow/theme/app_theme.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/balance_calendar.dart';
import 'package:money_flow/views/widgets/balance_chart.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de balances
              _buildBalanceSummary(),
              const SizedBox(height: 24),
              
              // Título de gráfico
              const Text(
                'Evolución del Mes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const BalanceChart(),
              const SizedBox(height: 24),
              
              // Calendario
              const Text(
                'Balance Diario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const BalanceCalendar(),
              const SizedBox(height: 24),
              
              // Últimas transacciones
              _buildRecentTransactions(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildBalanceSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Ingresos',
            '\$${controller.totalIncome.value.toStringAsFixed(2)}',
            AppColors.secondary,
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Gastos',
            '\$${controller.totalExpense.value.toStringAsFixed(2)}',
            AppColors.danger,
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Balance',
            '\$${controller.balance.value.toStringAsFixed(2)}',
            controller.balance.value >= 0 ? AppColors.primary : AppColors.danger,
            Icons.account_balance,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
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
                  color: AppColors.textSecondary,
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
  
  Widget _buildRecentTransactions() {
    final recent = controller.monthlyTransactions.take(5).toList();
    
    if (recent.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No hay transacciones recientes'),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Últimos Movimientos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...recent.map((transaction) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.type == 'income'
                  ? AppColors.secondary.withOpacity(0.2)
                  : AppColors.danger.withOpacity(0.2),
              child: Icon(
                transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                color: transaction.type == 'income' ? AppColors.secondary : AppColors.danger,
                size: 20,
              ),
            ),
            title: Text(transaction.description),
            subtitle: Text(
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              '${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.type == 'income' ? AppColors.secondary : AppColors.danger,
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:money_flow/controllers/calendar_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/transaction_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              controller.onDateSelected(DateTime.now());
              controller.focusedDate.value = DateTime.now();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            // Calendario
            _buildCalendar(controller),
            
            // Transacciones del día seleccionado
            _buildDayTransactions(controller),
          ],
        );
      }),
    );
  }
  
  Widget _buildCalendar(CalendarController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: controller.focusedDate.value,
        selectedDayPredicate: (day) {
          return isSameDay(controller.selectedDate.value, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          controller.onDateSelected(selectedDay);
          controller.focusedDate.value = focusedDay;
        },
        onPageChanged: (focusedDay) {
          controller.onMonthChanged(focusedDay);
        },
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.red),
          defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
          outsideTextStyle: const TextStyle(color: AppColors.textLight),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final balance = controller.getBalanceForDay(date);
            
            if (balance != 0) {
              return Container(
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: balance > 0 
                      ? AppColors.secondary.withOpacity(0.2)
                      : AppColors.danger.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  balance > 0 
                      ? '+${balance.toStringAsFixed(0)}'
                      : balance.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 9,
                    color: balance > 0 ? AppColors.secondary : AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
  
  Widget _buildDayTransactions(CalendarController controller) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transacciones del día',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(controller.selectedDate.value),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDaySummary(controller),
            const SizedBox(height: 8),
            Expanded(
              child: _buildTransactionsList(controller),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDaySummary(CalendarController controller) {
    final transactions = controller.selectedDayTransactions;
    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryChip(
            'Ingresos',
            '\$${totalIncome.toStringAsFixed(2)}',
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryChip(
            'Gastos',
            '\$${totalExpense.toStringAsFixed(2)}',
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
  
  Widget _buildTransactionsList(CalendarController controller) {
    final transactions = controller.selectedDayTransactions;
    
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No hay transacciones este día',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: TransactionCard(
            transaction: transaction,
            categoryName: controller.getCategoryName(transaction.categoryId),
            categoryIcon: controller.getCategoryIcon(transaction.categoryId),
            onTap: () {
              // TODO: Ver detalle de transacción
              Get.snackbar('Info', 'Detalle en desarrollo');
            },
            onDelete: () {
              // TODO: Eliminar transacción
              Get.snackbar('Info', 'Eliminar en desarrollo');
            },
          ),
        );
      },
    );
  }
}
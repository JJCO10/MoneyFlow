import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/views/screens/edit_transaction_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:money_flow/controllers/calendar_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/transaction_card.dart';
import 'package:money_flow/l10n/translations.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('calendar_title'.t),
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
            _buildCalendar(controller, isDark),
            _buildDayTransactions(controller, isDark),
          ],
        );
      }),
    );
  }
  
  Widget _buildCalendar(CalendarController controller, bool isDark) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textLight = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
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
          defaultTextStyle: TextStyle(
            color: textPrimary,
          ),
          outsideTextStyle: TextStyle(
            color: textLight,
          ),
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
  
  Widget _buildDayTransactions(CalendarController controller, bool isDark) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bgColor = isDark ? AppColors.darkBackground : Colors.grey[50];
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
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
                Text(
                  'transactions_day'.t,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(controller.selectedDate.value),
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDaySummary(controller, isDark),
            const SizedBox(height: 8),
            Expanded(
              child: _buildTransactionsList(controller, isDark),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDaySummary(CalendarController controller, bool isDark) {
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
            'income'.t,
            '\$${totalIncome.toStringAsFixed(2)}',
            AppColors.secondary,
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryChip(
            'expense'.t,
            '\$${totalExpense.toStringAsFixed(2)}',
            AppColors.danger,
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryChip(
            'balance'.t,
            '\$${balance.toStringAsFixed(2)}',
            balance >= 0 ? AppColors.primary : AppColors.danger,
            isDark,
          ),
        ),
      ],
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
  
  Widget _buildTransactionsList(CalendarController controller, bool isDark) {
    final transactions = controller.selectedDayTransactions;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final iconColor = isDark ? Colors.grey[600] : Colors.grey[400];
    
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: iconColor),
            const SizedBox(height: 8),
            Text(
              'no_transactions_day'.t,
              style: TextStyle(
                color: textSecondary,
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
            onTap: () async {
              final result = await Get.to(() => EditTransactionScreen(
                transaction: transaction,
              ));
              if (result == true) {
                controller.loadCalendarData();
              }
            },
            onDelete: () {
              Get.snackbar('info'.t, 'delete'.t);
            },
          ),
        );
      },
    );
  }
}
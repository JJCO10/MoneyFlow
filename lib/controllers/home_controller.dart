import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';

class HomeController extends GetxController {
  final TransactionService _transactionService = Get.find();
  
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var balance = 0.0.obs;
  var monthlyTransactions = <Transaction>[].obs;
  var dailyBalances = <DateTime, double>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final transactions = await _transactionService.getTransactionsBetween(startOfMonth, endOfMonth);
    monthlyTransactions.value = transactions;
    
    // Calcular totales
    totalIncome.value = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
        
    totalExpense.value = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
        
    balance.value = totalIncome.value - totalExpense.value;
    
    // Calcular balances diarios
    calculateDailyBalances(transactions);
  }
  
  void calculateDailyBalances(List<Transaction> transactions) {
    dailyBalances.clear();
    for (var transaction in transactions) {
      final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      final amount = transaction.type == 'income' ? transaction.amount : -transaction.amount;
      dailyBalances[date] = (dailyBalances[date] ?? 0) + amount;
    }
  }
}
import 'package:get/get.dart';
import 'package:money_flow/database/database_helper.dart';
import 'package:money_flow/models/transaction_model.dart';

class TransactionService extends GetxService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Transaction>> getAllTransactions() async {
    return await _db.getAllTransactions();
  }

  Future<List<Transaction>> getTransactionsBetween(DateTime start, DateTime end) async {
    return await _db.getTransactionsBetween(start, end);
  }

  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    return await _db.getTransactionsByCategory(categoryId);
  }

  Future<List<Transaction>> getCurrentMonthTransactions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return await getTransactionsBetween(startOfMonth, endOfMonth);
  }

  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    return await _db.getSumByTypeAndDate('income', start, end);
  }

  Future<double> getTotalExpense(DateTime start, DateTime end) async {
    return await _db.getSumByTypeAndDate('expense', start, end);
  }

  Future<double> getBalance(DateTime start, DateTime end) async {
    final income = await getTotalIncome(start, end);
    final expense = await getTotalExpense(start, end);
    return income - expense;
  }

  Future<void> saveTransaction(Transaction transaction) async {
    if (transaction.id == null) {
      await _db.insertTransaction(transaction);
    } else {
      await _db.updateTransaction(transaction);
    }
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
  }
}
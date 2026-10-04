import 'package:get/get.dart';
import 'package:money_flow/database/database_helper.dart';
import 'package:money_flow/models/transaction_model.dart';

class TransactionService extends GetxService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Transaction>> getAllTransactions() async {
    return await _db.getAllTransactions();
  }

  Future<List<Transaction>> getTransactionsBetween(
      DateTime start, DateTime end) async {
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

  // 🔥 OBTENER TRANSACCIÓN POR ID
  Future<Transaction?> getTransactionById(int id) async {
    return await _db.getTransactionById(id);
  }

  Future<void> saveTransaction(Transaction transaction) async {
    if (transaction.id == null) {
      await _db.insertTransaction(transaction);
    } else {
      await _db.updateTransaction(transaction);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _db.updateTransaction(transaction);
  }

  // 🔥 ELIMINAR TRANSACCIÓN CON LÓGICA DE RECURRENCIA
  Future<void> deleteTransaction(int id) async {
    // Obtener la transacción por ID (funciona para padre, hija y normal)
    final transaction = await _db.getTransactionById(id);

    if (transaction == null) {
      throw Exception('Transacción no encontrada');
    }

    // 🔥 CASO 1: TRANSACCIÓN PADRE RECURRENTE
    if (transaction.isRecurring && transaction.parentId == null) {
      print('🗑️ Eliminando transacción recurrente PADRE y sus hijas');
      await _db.deleteTransactionWithChildren(id);
      return;
    }

    // 🔥 CASO 2: TRANSACCIÓN HIJA (generada por recurrencia)
    if (transaction.parentId != null) {
      print('🗑️ Eliminando transacción HIJA');

      // 🔥 REGISTRAR LA FECHA COMO ELIMINADA PARA QUE NO SE REGENERE
      await _db.registerDeletedDate(transaction.parentId!, transaction.date);

      await _db.deleteTransaction(id);
      return;
    }

    // 🔥 CASO 3: TRANSACCIÓN NORMAL
    print('🗑️ Eliminando transacción NORMAL');
    await _db.deleteTransaction(id);
  }

  // 🔥 ELIMINAR TRANSACCIÓN PADRE Y TODAS SUS HIJAS
  Future<void> deleteParentWithChildren(int parentId) async {
    print('🗑️ Eliminando recurrencia completa: padre + hijas');
    await _db.deleteTransactionWithChildren(parentId);
  }

  // 🔥 OBTENER TRANSACCIONES RECURRENTES (PADRES)
  Future<List<Transaction>> getRecurringTransactions() async {
    return await _db.getRecurringTransactions();
  }

  // 🔥 OBTENER TRANSACCIONES HIJAS DE UNA RECURRENTE
  Future<List<Transaction>> getChildTransactions(int parentId) async {
    return await _db.getChildTransactions(parentId);
  }

  // 🔥 OBTENER FECHAS ELIMINADAS DE UN PADRE
  Future<List<DateTime>> getDeletedDates(int parentId) async {
    return await _db.getDeletedDates(parentId);
  }

  // 🔥 LIMPIAR FECHAS ELIMINADAS DE UN PADRE
  Future<void> clearDeletedDates(int parentId) async {
    await _db.clearDeletedDates(parentId);
  }
}

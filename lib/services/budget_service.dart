import 'package:get/get.dart';
import 'package:money_flow/database/database_helper.dart';
import 'package:money_flow/models/budget_model.dart';
import 'package:money_flow/models/transaction_model.dart';

class BudgetService extends GetxService {
  final DatabaseHelper _db = DatabaseHelper();

  // Guardar o actualizar presupuesto
  Future<void> saveBudget(Budget budget) async {
    final db = await _db.database;
    
    if (budget.id == null) {
      // Insertar nuevo
      await db.insert('budgets', budget.toMap());
    } else {
      // Actualizar existente
      final updatedBudget = Budget(
        id: budget.id,
        categoryId: budget.categoryId,
        limit: budget.limit,
        period: budget.period,
        createdAt: budget.createdAt,
        updatedAt: DateTime.now(),
      );
      await db.update(
        'budgets',
        updatedBudget.toMap(),
        where: 'id = ?',
        whereArgs: [budget.id],
      );
    }
  }

  // Obtener todos los presupuestos
  Future<List<Budget>> getAllBudgets() async {
    final db = await _db.database;
    final result = await db.query('budgets');
    return result.map((map) => Budget.fromMap(map)).toList();
  }

  // Obtener presupuesto por categoría
  Future<Budget?> getBudgetByCategory(int categoryId) async {
    final db = await _db.database;
    final result = await db.query(
      'budgets',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    
    if (result.isEmpty) return null;
    return Budget.fromMap(result.first);
  }

  // Eliminar presupuesto
  Future<void> deleteBudget(int id) async {
    final db = await _db.database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener gastos de una categoría en el mes actual
  Future<double> getCategorySpending(int categoryId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final transactions = await _db.getTransactionsBetween(startOfMonth, endOfMonth);
    
    // Filtrar transacciones de la categoría y tipo gasto
    double total = 0.0;
    for (var transaction in transactions) {
      if (transaction.categoryId == categoryId && transaction.type == 'expense') {
        total += transaction.amount;
      }
    }
    return total;
  }

  // Obtener progreso de presupuesto (porcentaje)
  Future<double> getBudgetProgress(int categoryId) async {
    final budget = await getBudgetByCategory(categoryId);
    if (budget == null) return 0.0;
    
    final spent = await getCategorySpending(categoryId);
    return (spent / budget.limit) * 100;
  }
}
import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';

class ChartController extends GetxController {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();
  
  var isLoading = false.obs;
  var monthlyIncome = 0.0.obs;
  var monthlyExpense = 0.0.obs;
  var dailyBalances = <Map<String, dynamic>>[].obs;
  var categoryExpenses = <Map<String, dynamic>>[].obs;
  var transactions = <Transaction>[].obs;
  var categories = <Category>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadChartData();
  }
  
  Future<void> loadChartData() async {
    try {
      isLoading.value = true;
      
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      // Obtener transacciones del mes
      transactions.value = await _transactionService.getTransactionsBetween(
        startOfMonth,
        endOfMonth,
      );
      
      // Obtener categorías
      categories.value = await _categoryService.getAllCategories();
      
      // Calcular ingresos y gastos del mes
      monthlyIncome.value = transactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.amount);
          
      monthlyExpense.value = transactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      
      // Calcular balances diarios
      _calculateDailyBalances();
      
      // Calcular gastos por categoría
      _calculateCategoryExpenses();
      
    } catch (e) {
      print('❌ Error cargando datos de gráficos: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _calculateDailyBalances() {
    final Map<String, double> dailyMap = {};
    
    for (var transaction in transactions) {
      final dateKey = '${transaction.date.day}/${transaction.date.month}';
      final amount = transaction.type == 'income' 
          ? transaction.amount 
          : -transaction.amount;
          
      dailyMap[dateKey] = (dailyMap[dateKey] ?? 0) + amount;
    }
    
    // Convertir a lista ordenada
    final sortedKeys = dailyMap.keys.toList()..sort((a, b) {
      final partsA = a.split('/');
      final partsB = b.split('/');
      final dayA = int.parse(partsA[0]);
      final dayB = int.parse(partsB[0]);
      return dayA.compareTo(dayB);
    });
    
    dailyBalances.value = sortedKeys.map((key) {
      return {
        'day': key,
        'balance': dailyMap[key] ?? 0.0,
      };
    }).toList();
  }
  
  void _calculateCategoryExpenses() {
    final Map<int, double> categoryMap = {};
    
    // Solo gastos
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    
    for (var transaction in expenses) {
      categoryMap[transaction.categoryId] = 
          (categoryMap[transaction.categoryId] ?? 0) + transaction.amount;
    }
    
    // Obtener nombres de categorías
    final cats = categories.value;
    
    categoryExpenses.value = categoryMap.entries.map((entry) {
      // Buscar la categoría - versión compatible con versiones anteriores
      Category? category;
      for (var c in cats) {
        if (c.id == entry.key) {
          category = c;
          break;
        }
      }
      return {
        'categoryId': entry.key,
        'name': category?.name ?? 'Sin categoría',
        'icon': category?.icon ?? '📌',
        'color': category?.color ?? 0xFF3B82F6,
        'amount': entry.value,
      };
    }).toList()
    ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
  }
  
  // Formatear moneda
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
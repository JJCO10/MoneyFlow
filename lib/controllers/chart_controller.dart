import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/models/time_range.dart';

class ChartController extends GetxController {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();
  
  // 🔥 INICIALIZAR CON true para mostrar carga inmediatamente
  var isLoading = true.obs; // <-- CAMBIAR A true
  var selectedRange = TimeRange.monthly.obs;
  
  // Datos filtrados
  var filteredTransactions = <Transaction>[].obs;
  var monthlyIncome = 0.0.obs;
  var monthlyExpense = 0.0.obs;
  var categoryExpenses = <Map<String, dynamic>>[].obs;
  
  // Datos para evolución mensual
  var monthlyEvolution = <Map<String, dynamic>>[].obs;
  
  // Datos para comparativa anual
  var annualComparison = <Map<String, dynamic>>[].obs;
  
  // Datos para balance diario (oculto)
  var dailyBalances = <Map<String, dynamic>>[].obs;
  
  // Cache de categorías
  List<Category> _cachedCategories = [];
  
  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    _cachedCategories = await _categoryService.getAllCategories();
    await loadChartData();
  }
  
  Future<void> loadChartData() async {
    try {
      isLoading.value = true;
      
      // Obtener todas las transacciones
      final allTransactions = await _transactionService.getAllTransactions();
      
      // Filtrar por rango de tiempo
      final startDate = _getStartDate(selectedRange.value);
      filteredTransactions.value = allTransactions
          .where((t) => t.date.isAfter(startDate))
          .toList();
      
      // Calcular ingresos y gastos
      monthlyIncome.value = filteredTransactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.amount);
          
      monthlyExpense.value = filteredTransactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      
      // Calcular gastos por categoría
      _calculateCategoryExpenses();
      
      // Calcular evolución mensual
      _calculateMonthlyEvolution();
      
      // Calcular comparativa anual
      _calculateAnnualComparison();
      
      // Calcular balances diarios (oculto)
      _calculateDailyBalances();
      
    } catch (e) {
      print('❌ Error cargando datos de gráficos: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  DateTime _getStartDate(TimeRange range) {
    final now = DateTime.now();
    switch (range) {
      case TimeRange.daily:
        return now.subtract(const Duration(days: 7));
      case TimeRange.weekly:
        return now.subtract(const Duration(days: 28));
      case TimeRange.monthly:
        return now.subtract(const Duration(days: 180));
      case TimeRange.semestral:
        return now.subtract(const Duration(days: 365));
      case TimeRange.annual:
        return now.subtract(const Duration(days: 730));
      case TimeRange.all:
        return DateTime(2020, 1, 1);
    }
  }
  
  void changeRange(TimeRange range) {
    selectedRange.value = range;
    loadChartData();
  }
  
  void _calculateCategoryExpenses() {
    final Map<int, double> categoryMap = {};
    
    final expenses = filteredTransactions.where((t) => t.type == 'expense').toList();
    
    for (var transaction in expenses) {
      categoryMap[transaction.categoryId] = 
          (categoryMap[transaction.categoryId] ?? 0) + transaction.amount;
    }
    
    categoryExpenses.value = categoryMap.entries.map((entry) {
      String categoryName = 'Sin categoría';
      String categoryIcon = '📌';
      int categoryColor = 0xFF3B82F6;
      
      for (var cat in _cachedCategories) {
        if (cat.id == entry.key) {
          categoryName = cat.name;
          categoryIcon = cat.icon;
          categoryColor = cat.color;
          break;
        }
      }
      
      return {
        'categoryId': entry.key,
        'name': categoryName,
        'icon': categoryIcon,
        'color': categoryColor,
        'amount': entry.value,
      };
    }).toList()
    ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
  }
  
  void _calculateMonthlyEvolution() {
    final Map<String, double> monthlyMap = {};
    
    const monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    for (var month in monthNames) {
      monthlyMap[month] = 0.0;
    }
    
    for (var transaction in filteredTransactions) {
      final monthName = _getShortMonthName(transaction.date.month);
      final amount = transaction.type == 'income' ? transaction.amount : -transaction.amount;
      monthlyMap[monthName] = (monthlyMap[monthName] ?? 0) + amount;
    }
    
    final monthOrder = {
      'Ene': 1, 'Feb': 2, 'Mar': 3, 'Abr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Ago': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dic': 12
    };
    
    final sortedKeys = monthlyMap.keys.toList()..sort((a, b) {
      return (monthOrder[a] ?? 0).compareTo(monthOrder[b] ?? 0);
    });
    
    monthlyEvolution.value = sortedKeys.map((key) {
      return {
        'month': key,
        'balance': monthlyMap[key] ?? 0.0,
      };
    }).toList();
  }
  
  String _getShortMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }
  
  void _calculateAnnualComparison() {
    final now = DateTime.now();
    final Map<int, Map<String, double>> annualMap = {};
    
    for (var i = 0; i < 12; i++) {
      final date = DateTime(now.year, i + 1, 1);
      final key = i + 1;
      annualMap[key] = {'income': 0.0, 'expense': 0.0};
    }
    
    for (var transaction in filteredTransactions) {
      final month = transaction.date.month;
      if (transaction.date.year == now.year) {
        if (transaction.type == 'income') {
          annualMap[month]!['income'] = 
              (annualMap[month]!['income'] ?? 0) + transaction.amount;
        } else {
          annualMap[month]!['expense'] = 
              (annualMap[month]!['expense'] ?? 0) + transaction.amount;
        }
      }
    }
    
    annualComparison.value = annualMap.entries.map((entry) {
      return {
        'month': entry.key,
        'income': entry.value['income'] ?? 0.0,
        'expense': entry.value['expense'] ?? 0.0,
      };
    }).toList();
  }
  
  void _calculateDailyBalances() {
    final Map<String, double> dailyMap = {};
    
    for (var transaction in filteredTransactions) {
      final dateKey = '${transaction.date.day}/${transaction.date.month}';
      final amount = transaction.type == 'income' 
          ? transaction.amount 
          : -transaction.amount;
          
      dailyMap[dateKey] = (dailyMap[dateKey] ?? 0) + amount;
    }
    
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
  
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
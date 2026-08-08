import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/models/category_model.dart';

class CalendarController extends GetxController {
  final TransactionService _transactionService = Get.find();
  final CategoryService _categoryService = Get.find();
  
  var isLoading = false.obs;
  var selectedDate = DateTime.now().obs;
  var focusedDate = DateTime.now().obs;
  var dailyBalances = <DateTime, double>{}.obs;
  var selectedDayTransactions = <Transaction>[].obs;
  var allTransactions = <Transaction>[].obs;
  var categories = <Category>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCalendarData();
  }
  
  Future<void> loadCalendarData() async {
    try {
      isLoading.value = true;
      
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      // Obtener categorías
      categories.value = await _categoryService.getAllCategories();
      
      // Obtener transacciones del mes
      allTransactions.value = await _transactionService.getTransactionsBetween(
        startOfMonth,
        endOfMonth,
      );
      
      // Calcular balances diarios
      _calculateDailyBalances();
      
      // Cargar transacciones del día seleccionado
      _loadDayTransactions(selectedDate.value);
      
    } catch (e) {
      print('❌ Error cargando datos del calendario: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _calculateDailyBalances() {
    final Map<DateTime, double> tempBalances = {};
    
    for (var transaction in allTransactions) {
      final dateKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      final amount = transaction.type == 'income' 
          ? transaction.amount 
          : -transaction.amount;
          
      tempBalances[dateKey] = (tempBalances[dateKey] ?? 0) + amount;
    }
    
    dailyBalances.value = tempBalances;
  }
  
  void _loadDayTransactions(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    selectedDayTransactions.value = allTransactions.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      return tDate == dateKey;
    }).toList();
  }
  
  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    _loadDayTransactions(date);
  }
  
  void onMonthChanged(DateTime date) {
    focusedDate.value = date;
    loadCalendarData();
  }
  
  double getBalanceForDay(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return dailyBalances[dateKey] ?? 0.0;
  }
  
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  // Métodos para obtener información de categorías
  String getCategoryName(int categoryId) {
    for (var cat in categories) {
      if (cat.id == categoryId) {
        return cat.name;
      }
    }
    return 'Sin categoría';
  }
  
  String getCategoryIcon(int categoryId) {
    for (var cat in categories) {
      if (cat.id == categoryId) {
        return cat.icon;
      }
    }
    return '📌';
  }
}
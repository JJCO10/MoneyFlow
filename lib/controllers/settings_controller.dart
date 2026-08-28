import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/shared_preferences_service.dart';
import 'package:money_flow/l10n/translations.dart';
import 'package:money_flow/services/notification_service.dart';

class SettingsController extends GetxController {
  final PreferencesService _prefs = Get.find();
  final AppTranslationsController _translations = Get.find();
  final NotificationService _notificationService = Get.find();
  
  var isDarkMode = false.obs;
  var selectedCurrency = '\$'.obs;
  var selectedLanguage = 'es'.obs;
  var dailySummaryEnabled = false.obs;
  var budgetAlertsEnabled = true.obs; // 🔥 AGREGADO
  
  final List<String> currencies = ['\$', '€', '£', '¥', 'R\$', 'MX\$', 'COP\$'];
  final List<Map<String, String>> languages = [
    {'code': 'es', 'name': 'Español'},
    {'code': 'en', 'name': 'English'},
  ];
  
  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _prefs.themeMode == 'dark';
    selectedCurrency.value = _prefs.currency;
    selectedLanguage.value = _prefs.language;
    dailySummaryEnabled.value = _prefs.dailySummaryEnabled;
    budgetAlertsEnabled.value = _prefs.budgetAlertsEnabled; // 🔥 AGREGADO
    _translations.currentLanguage.value = _prefs.language;
  }
  
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _prefs.themeMode = value ? 'dark' : 'light';
    Get.forceAppUpdate();
  }
  
  void changeCurrency(String currency) {
    selectedCurrency.value = currency;
    _prefs.currency = currency;
  }
  
  void changeLanguage(String language) {
    selectedLanguage.value = language;
    _prefs.language = language;
    _translations.changeLanguage(language);
    Get.updateLocale(Locale(language));
  }
  
  // 🔥 TOGGLE RESUMEN DIARIO
  Future<void> toggleDailySummary(bool value) async {
    dailySummaryEnabled.value = value;
    _prefs.dailySummaryEnabled = value;
    
    if (value) {
      await _notificationService.scheduleDailySummaryIfEnabled();
      Get.snackbar(
        'Notificaciones',
        'Resumen diario activado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      await _notificationService.cancelNotification(999);
      Get.snackbar(
        'Notificaciones',
        'Resumen diario desactivado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  // 🔥 TOGGLE ALERTAS DE PRESUPUESTO
  Future<void> toggleBudgetAlerts(bool value) async {
    budgetAlertsEnabled.value = value;
    _prefs.budgetAlertsEnabled = value;
    
    Get.snackbar(
      'Notificaciones',
      value ? 'Alertas de presupuesto activadas' : 'Alertas de presupuesto desactivadas',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: value ? Colors.green : Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
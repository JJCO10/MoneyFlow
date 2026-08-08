import 'dart:ui';

import 'package:get/get.dart';
import 'package:money_flow/services/shared_preferences_service.dart';

class SettingsController extends GetxController {
  final PreferencesService _prefs = Get.find();
  
  var isDarkMode = false.obs;
  var selectedCurrency = '\$'.obs;
  var selectedLanguage = 'es'.obs;
  
  final List<String> currencies = ['\$', '€', '£', '¥', 'R\$', 'MX\$', 'COP\$'];
  final List<Map<String, String>> languages = [
    {'code': 'es', 'name': 'Español'},
    {'code': 'en', 'name': 'English'},
  ];
  
  @override
  void onInit() {
    super.onInit();
    // Cargar preferencias guardadas
    isDarkMode.value = _prefs.themeMode == 'dark';
    selectedCurrency.value = _prefs.currency;
    selectedLanguage.value = _prefs.language;
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
    // TODO: Implementar cambio de idioma con GetX
    Get.updateLocale(Locale(language));
  }
}
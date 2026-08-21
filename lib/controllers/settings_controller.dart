import 'dart:ui';

import 'package:get/get.dart';
import 'package:money_flow/services/shared_preferences_service.dart';
import 'package:money_flow/l10n/translations.dart';

class SettingsController extends GetxController {
  final PreferencesService _prefs = Get.find();
  final AppTranslationsController _translations = Get.find();
  
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
    isDarkMode.value = _prefs.themeMode == 'dark';
    selectedCurrency.value = _prefs.currency;
    selectedLanguage.value = _prefs.language;
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
    print('🌐 Cambiando idioma en settings: $language');
    selectedLanguage.value = language;
    _prefs.language = language;
    
    final translationsController = Get.find<AppTranslationsController>();
    translationsController.changeLanguage(language);
    
    Get.updateLocale(Locale(language));
    print('✅ Idioma actualizado a: $language');
  }
}
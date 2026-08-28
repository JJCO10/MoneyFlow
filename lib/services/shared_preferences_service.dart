import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class PreferencesService extends GetxService {
  static const String _themeKey = 'theme_mode';
  static const String _currencyKey = 'currency';
  static const String _languageKey = 'language';
  static const String _dailySummaryKey = 'daily_summary';
  static const String _budgetAlertsKey = 'budget_alerts'; // 🔥 NUEVO
  
  late SharedPreferences _prefs;
  
  Future<PreferencesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  String get themeMode => _prefs.getString(_themeKey) ?? 'light';
  set themeMode(String value) => _prefs.setString(_themeKey, value);
  
  String get currency => _prefs.getString(_currencyKey) ?? '\$';
  set currency(String value) => _prefs.setString(_currencyKey, value);
  
  String get language => _prefs.getString(_languageKey) ?? 'es';
  set language(String value) => _prefs.setString(_languageKey, value);
  
  bool get dailySummaryEnabled => _prefs.getBool(_dailySummaryKey) ?? false;
  set dailySummaryEnabled(bool value) => _prefs.setBool(_dailySummaryKey, value);
  
  // 🔥 GET/SET ALERTAS DE PRESUPUESTO
  bool get budgetAlertsEnabled => _prefs.getBool(_budgetAlertsKey) ?? true;
  set budgetAlertsEnabled(bool value) => _prefs.setBool(_budgetAlertsKey, value);
}
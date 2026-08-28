import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class PreferencesService extends GetxService {
  static const String _themeKey = 'theme_mode';
  static const String _currencyKey = 'currency';
  static const String _languageKey = 'language';
  static const String _dailySummaryKey = 'daily_summary';
  static const String _budgetAlertsKey = 'budget_alerts';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _onboardingCompletedKey = 'onboarding_completed'; // 🔥 NUEVO
  
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
  
  bool get budgetAlertsEnabled => _prefs.getBool(_budgetAlertsKey) ?? true;
  set budgetAlertsEnabled(bool value) => _prefs.setBool(_budgetAlertsKey, value);
  
  bool get hapticFeedbackEnabled => _prefs.getBool(_hapticFeedbackKey) ?? true;
  set hapticFeedbackEnabled(bool value) => _prefs.setBool(_hapticFeedbackKey, value);
  
  // 🔥 GET/SET ONBOARDING
  bool get onboardingCompleted => _prefs.getBool(_onboardingCompletedKey) ?? false;
  set onboardingCompleted(bool value) => _prefs.setBool(_onboardingCompletedKey, value);
}
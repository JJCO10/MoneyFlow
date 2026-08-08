import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class PreferencesService extends GetxService {
  static const String _themeKey = 'theme_mode';
  static const String _currencyKey = 'currency';
  static const String _languageKey = 'language';
  
  late SharedPreferences _prefs;
  
  Future<PreferencesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  // Tema
  String get themeMode => _prefs.getString(_themeKey) ?? 'light';
  set themeMode(String value) => _prefs.setString(_themeKey, value);
  
  // Moneda
  String get currency => _prefs.getString(_currencyKey) ?? '\$';
  set currency(String value) => _prefs.setString(_currencyKey, value);
  
  // Idioma
  String get language => _prefs.getString(_languageKey) ?? 'es';
  set language(String value) => _prefs.setString(_languageKey, value);
}
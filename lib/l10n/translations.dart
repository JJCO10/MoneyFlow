import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static const supportedLocales = ['es', 'en'];
  static const fallbackLocale = 'es';

  @override
  Map<String, Map<String, String>> get keys => {};

  static Future<Map<String, Map<String, String>>> loadTranslations() async {
    final Map<String, Map<String, String>> translations = {};

    for (var locale in supportedLocales) {
      try {
        print('📂 Cargando traducciones para: $locale');
        final jsonString = await rootBundle.loadString(
          'lib/l10n/locales/$locale.json',
        );
        print('✅ JSON cargado para $locale');
        
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        translations[locale] = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        print('❌ Error cargando traducciones para $locale: $e');
        if (locale != 'es') {
          try {
            final jsonString = await rootBundle.loadString(
              'lib/l10n/locales/es.json',
            );
            final Map<String, dynamic> jsonMap = json.decode(jsonString);
            translations[locale] = jsonMap.map((key, value) => MapEntry(key, value.toString()));
          } catch (_) {
            translations[locale] = {};
          }
        } else {
          translations[locale] = {};
        }
      }
    }

    print('📚 Traducciones cargadas: ${translations.keys}');
    return translations;
  }
}

// ✅ EXTENSIÓN CORRECTA: .t
extension TranslateExtension on String {
  String get t {
    try {
      final result = Get.find<AppTranslationsController>().translate(this);
      print('🔍 Traduciendo "$this" -> "$result"');
      return result;
    } catch (e) {
      print('❌ Error traduciendo "$this": $e');
      return this;
    }
  }
}

class AppTranslationsController extends GetxController {
  static AppTranslationsController get to => Get.find();

  final Map<String, Map<String, String>> _translations = {};
  var currentLanguage = 'es'.obs;

  @override
  void onInit() {
    super.onInit();
    print('🌐 Inicializando AppTranslationsController...');
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    print('📖 Cargando traducciones...');
    final translations = await AppTranslations.loadTranslations();
    _translations.addAll(translations);
    print('✅ Traducciones cargadas en el controlador: ${_translations.keys}');
  }

  String translate(String key) {
    final lang = currentLanguage.value;
    print('🔍 Buscando "$key" en idioma: $lang');
    
    if (_translations.containsKey(lang) && _translations[lang]!.containsKey(key)) {
      final result = _translations[lang]![key]!;
      print('✅ Encontrado: "$result"');
      return result;
    }
    
    if (_translations.containsKey('es') && _translations['es']!.containsKey(key)) {
      final result = _translations['es']![key]!;
      print('⚠️ Fallback a español: "$result"');
      return result;
    }
    
    print('❌ No encontrado para "$key"');
    return key;
  }

  void changeLanguage(String languageCode) {
    if (!AppTranslations.supportedLocales.contains(languageCode)) {
      print('⚠️ Idioma no soportado: $languageCode');
      return;
    }
    print('🌐 Cambiando idioma de ${currentLanguage.value} a $languageCode');
    currentLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));
  }
}
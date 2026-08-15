import 'package:flutter/foundation.dart';

class AppInfo {
  // Package name fijo (puedes cambiarlo por tu package name real)
  static const String packageName = 'com.example.money_flow';
  
  // Obtener el package name dinámicamente (fallback)
  static String getPackageName() {
    // En release, usar el valor fijo
    // En debug, también usar el valor fijo
    return packageName;
  }
}
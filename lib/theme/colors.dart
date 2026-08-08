import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal - Tonos azules y verdes para finanzas
  static const Color primary = Color(0xFF2563EB);      // Azul principal
  static const Color primaryDark = Color(0xFF1D4ED8);   // Azul oscuro
  static const Color primaryLight = Color(0xFF60A5FA);  // Azul claro
  
  static const Color secondary = Color(0xFF10B981);     // Verde para ingresos
  static const Color secondaryLight = Color(0xFF34D399);
  
  static const Color danger = Color(0xFFEF4444);        // Rojo para gastos
  static const Color warning = Color(0xFFF59E0B);
  
  // Neutros
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
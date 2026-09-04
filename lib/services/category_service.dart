import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:money_flow/database/database_helper.dart';
import 'package:money_flow/models/category_model.dart';

class CategoryService extends GetxService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Category>> getAllCategories() async {
    return await _db.getAllCategories();
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    return await _db.getCategoriesByType(type);
  }

  Future<Category?> getCategoryById(int id) async {
    return await _db.getCategoryById(id);
  }

  Future<void> saveCategory(Category category) async {
    if (category.id == null) {
      await _db.insertCategory(category);
    } else {
      await _db.updateCategory(category);
    }
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
  }

  // 🔥 MÉTODO ACTUALIZADO: Cargar categorías según idioma
  Future<void> loadDefaultCategories() async {
    final existing = await getAllCategories();
    if (existing.isNotEmpty) return;
    
    final String languageCode = PlatformDispatcher.instance.locale.languageCode;
    final bool useSpanish = languageCode == 'es';
    
    final defaultCategories = useSpanish 
        ? _getSpanishDefaultCategories() 
        : _getEnglishDefaultCategories();

    for (var category in defaultCategories) {
      await saveCategory(category);
    }
    
    print('✅ Categorías por defecto cargadas en ${useSpanish ? "Español" : "Inglés"}');
  }

  // 🔥 CATEGORÍAS EN ESPAÑOL
  List<Category> _getSpanishDefaultCategories() {
    return [
      Category(name: 'Alimentación', type: 'expense', icon: '🍽️', color: 0xFFEF4444, isDefault: true),
      Category(name: 'Transporte', type: 'expense', icon: '🚗', color: 0xFF3B82F6, isDefault: true),
      Category(name: 'Compras', type: 'expense', icon: '🛍️', color: 0xFF8B5CF6, isDefault: true),
      Category(name: 'Salud', type: 'expense', icon: '🏥', color: 0xFF10B981, isDefault: true),
      Category(name: 'Educación', type: 'expense', icon: '📚', color: 0xFFF59E0B, isDefault: true),
      Category(name: 'Entretenimiento', type: 'expense', icon: '🎬', color: 0xFFEC4899, isDefault: true),
      Category(name: 'Hogar', type: 'expense', icon: '🏠', color: 0xFF14B8A6, isDefault: true),
      Category(name: 'Salario', type: 'income', icon: '💰', color: 0xFF10B981, isDefault: true),
      Category(name: 'Freelance', type: 'income', icon: '💻', color: 0xFF3B82F6, isDefault: true),
      Category(name: 'Inversiones', type: 'income', icon: '📈', color: 0xFF8B5CF6, isDefault: true),
    ];
  }

  // 🔥 CATEGORÍAS EN INGLÉS
  List<Category> _getEnglishDefaultCategories() {
    return [
      Category(name: 'Food', type: 'expense', icon: '🍽️', color: 0xFFEF4444, isDefault: true),
      Category(name: 'Transport', type: 'expense', icon: '🚗', color: 0xFF3B82F6, isDefault: true),
      Category(name: 'Shopping', type: 'expense', icon: '🛍️', color: 0xFF8B5CF6, isDefault: true),
      Category(name: 'Health', type: 'expense', icon: '🏥', color: 0xFF10B981, isDefault: true),
      Category(name: 'Education', type: 'expense', icon: '📚', color: 0xFFF59E0B, isDefault: true),
      Category(name: 'Entertainment', type: 'expense', icon: '🎬', color: 0xFFEC4899, isDefault: true),
      Category(name: 'Home', type: 'expense', icon: '🏠', color: 0xFF14B8A6, isDefault: true),
      Category(name: 'Salary', type: 'income', icon: '💰', color: 0xFF10B981, isDefault: true),
      Category(name: 'Freelance', type: 'income', icon: '💻', color: 0xFF3B82F6, isDefault: true),
      Category(name: 'Investments', type: 'income', icon: '📈', color: 0xFF8B5CF6, isDefault: true),
    ];
  }
}
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

  Future<void> loadDefaultCategories() async {
    final existing = await getAllCategories();
    if (existing.isNotEmpty) return;
    
    // Las categorías por defecto ya se insertan en el onCreate
    // Solo necesitamos asegurarnos de que la base de datos se inicialice
    await _db.database;
  }
}
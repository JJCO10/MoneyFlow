import 'package:floor/floor.dart';
import 'package:money_flow/models/category_model.dart';

@dao
abstract class CategoryDao {
  @Query('SELECT * FROM categories ORDER BY name ASC')
  Future<List<Category>> getAllCategories();
  
  @Query('SELECT * FROM categories WHERE type = :type')
  Future<List<Category>> getCategoriesByType(String type);
  
  @Query('SELECT * FROM categories WHERE id = :id')
  Future<Category?> getCategoryById(int id);
  
  @insert
  Future<void> insertCategory(Category category);
  
  @update
  Future<void> updateCategory(Category category);
  
  @delete
  Future<void> deleteCategory(Category category);
}
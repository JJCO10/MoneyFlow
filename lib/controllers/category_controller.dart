import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/l10n/translations.dart';

class CategoryController extends GetxController {
  final CategoryService _categoryService = Get.find();
  
  var categories = <Category>[].obs;
  var isLoading = false.obs;
  
  // Iconos disponibles
  final List<String> availableIcons = [
    '🍽️', '🚗', '🛍️', '🏥', '📚', '🎬', '🏠', '💰', '💻', '📈',
    '☕', '🍕', '🎮', '📱', '💊', '✈️', '🏋️', '🎯', '📝', '🎵',
  ];
  
  // Colores disponibles
  final List<int> availableColors = [
    0xFFEF4444, 0xFF3B82F6, 0xFF10B981, 0xFFF59E0B, 0xFF8B5CF6,
    0xFFEC4899, 0xFF14B8A6, 0xFFF97316, 0xFF6366F1, 0xFF06B6D4,
  ];
  
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }
  
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      categories.value = await _categoryService.getAllCategories();
    } catch (e) {
      print('❌ Error cargando categorías: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> addCategory({
    required String name,
    required String type,
    required String icon,
    required int color,
  }) async {
    try {
      final category = Category(
        name: name,
        type: type,
        icon: icon,
        color: color,
        isDefault: false,
      );
      
      await _categoryService.saveCategory(category);
      await loadCategories();
      
      Get.snackbar(
        'success'.t,
        'category_created'.t,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.t,
        'No se pudo crear la categoría',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // 🔥 MÉTODO DE EDICIÓN COMPLETO
  Future<void> editCategory(Category category) async {
    final nameController = TextEditingController(text: category.name);
    var selectedType = category.type.obs;
    var selectedIcon = category.icon.obs;
    var selectedColor = category.color.obs;
    
    Get.dialog(
      AlertDialog(
        title: Text('edit'.t),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la categoría',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tipo (Ingreso/Gasto)
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        'expense_type'.t,
                        'expense',
                        selectedType,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeOption(
                        'income_type'.t,
                        'income',
                        selectedType,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 16),
                
                // Iconos
                Text(
                  'Selecciona un ícono',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableIcons.map((icon) {
                    final isSelected = selectedIcon.value == icon;
                    return GestureDetector(
                      onTap: () => selectedIcon.value = icon,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 16),
                
                // Colores
                Text(
                  'Selecciona un color',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableColors.map((color) {
                    final isSelected = selectedColor.value == color;
                    return GestureDetector(
                      onTap: () => selectedColor.value = color,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.t),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'error'.t,
                  'El nombre es requerido',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              // 🔥 ACTUALIZAR CATEGORÍA
              final updatedCategory = Category(
                id: category.id,
                name: nameController.text,
                type: selectedType.value,
                icon: selectedIcon.value,
                color: selectedColor.value,
                isDefault: category.isDefault,
              );
              
              await _categoryService.saveCategory(updatedCategory);
              await loadCategories();
              Get.back();
              
              Get.snackbar(
                'success'.t,
                'Categoría actualizada correctamente',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('update'.t),
          ),
        ],
      ),
    );
  }
  
  Future<void> deleteCategory(int id) async {
    try {
      await _categoryService.deleteCategory(id);
      await loadCategories();
      
      Get.snackbar(
        'success'.t,
        'category_deleted'.t,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.t,
        'No se pudo eliminar la categoría',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  void showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    var selectedType = 'expense'.obs;
    var selectedIcon = '🍽️'.obs;
    var selectedColor = 0xFF3B82F6.obs;
    
    Get.dialog(
      AlertDialog(
        title: Text('Nueva Categoría'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la categoría',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tipo (Ingreso/Gasto)
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        'expense_type'.t,
                        'expense',
                        selectedType,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeOption(
                        'income_type'.t,
                        'income',
                        selectedType,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 16),
                
                // Iconos
                Text(
                  'Selecciona un ícono',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableIcons.map((icon) {
                    final isSelected = selectedIcon.value == icon;
                    return GestureDetector(
                      onTap: () => selectedIcon.value = icon,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 16),
                
                // Colores
                Text(
                  'Selecciona un color',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableColors.map((color) {
                    final isSelected = selectedColor.value == color;
                    return GestureDetector(
                      onTap: () => selectedColor.value = color,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.t),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'error'.t,
                  'El nombre es requerido',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              addCategory(
                name: nameController.text,
                type: selectedType.value,
                icon: selectedIcon.value,
                color: selectedColor.value,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('save'.t),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeOption(
    String label,
    String type,
    RxString selectedType,
  ) {
    final isSelected = selectedType.value == type;
    return GestureDetector(
      onTap: () => selectedType.value = type,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
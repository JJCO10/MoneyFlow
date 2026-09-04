import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/category_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/category_card.dart';
import 'package:money_flow/l10n/translations.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('categories_title'.t),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'no_categories'.t,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'add_category_message'.t,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextLight : AppColors.lightTextLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16).copyWith(
            bottom: 80,
          ),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            
            // 🔥 ELIMINAR LA CONDICIÓN isDefault
            // Ahora todas las categorías se pueden editar y eliminar
            return CategoryCard(
              category: category,
              onEdit: () => controller.editCategory(category), // 🔥 Siempre disponible
              onDelete: () => controller.deleteCategory(category.id!), // 🔥 Siempre disponible
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddCategoryDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
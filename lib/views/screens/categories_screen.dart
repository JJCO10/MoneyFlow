import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/category_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
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
                  'No hay categorías',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Presiona el botón + para agregar una',
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
            bottom: 80, // Espacio para el FAB
          ),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isDefault = category.isDefault;
            
            return CategoryCard(
              category: category,
              onEdit: isDefault ? null : () => controller.editCategory(category),
              onDelete: isDefault ? null : () => controller.deleteCategory(category.id!),
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
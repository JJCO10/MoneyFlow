import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/navigation_controller.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/screens/add_transaction_screen.dart';
import 'package:money_flow/views/screens/home_screen.dart';
import 'package:money_flow/views/screens/calendar_screen.dart';
import 'package:money_flow/views/screens/charts_screen.dart';
import 'package:money_flow/views/screens/categories_screen.dart';
import 'package:money_flow/views/screens/budgets_screen.dart';
import 'package:money_flow/views/widgets/animated_button.dart';
import 'package:money_flow/l10n/translations.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const ChartsScreen(),
      const CategoriesScreen(),
      const BudgetsScreen(),
    ];

    return Obx(() => Scaffold(
      body: screens[navController.selectedIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navController.selectedIndex.value,
        onTap: (index) {
          navController.changeTab(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home_title'.t,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: 'calendar_title'.t,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: 'charts_title'.t,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: 'categories_title'.t,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: 'budgets_title'.t,
          ),
        ],
      ),
      floatingActionButton: navController.selectedIndex.value == 0
          ? Container(
              margin: const EdgeInsets.only(bottom: 0), // 🔥 MÁRGEN INFERIOR
              child: AnimatedButton(
                onPressed: () async {
                  final result = await Get.to(() => AddTransactionScreen());
                  if (result == true) {
                    Get.snackbar(
                      'info'.t,
                      'data_updated'.t,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 1),
                    );
                  }
                },
                child: FloatingActionButton(
                  onPressed: null,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                  elevation: 4,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    ));
  }
}
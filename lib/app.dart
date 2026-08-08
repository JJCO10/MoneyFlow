import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/theme/app_theme.dart';
import 'package:money_flow/views/screens/home_screen.dart';
import 'package:money_flow/views/screens/settings_screen.dart';
import 'package:money_flow/views/screens/add_transaction_screen.dart';
import 'package:money_flow/views/screens/categories_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MoneyFlow',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/add-transaction', page: () => const AddTransactionScreen()),
        GetPage(name: '/categories', page: () => const CategoriesScreen()),
      ],
    );
  }
}
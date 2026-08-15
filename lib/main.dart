import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/services/export_service.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/shared_preferences_service.dart';
import 'package:money_flow/services/budget_service.dart';
import 'package:money_flow/views/screens/home_screen.dart';
import 'package:money_flow/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🔄 Iniciando servicios...');
    
    // Inicializar preferencias primero
    await Get.putAsync(() => PreferencesService().init());
    
    // Inicializar servicios
    Get.put(CategoryService());
    Get.put(TransactionService());
    Get.put(BudgetService()); // <-- AGREGADO
    Get.put(ExportService());
    
    print('✅ Servicios inicializados');
    
    // Cargar categorías por defecto
    final categoryService = Get.find<CategoryService>();
    await categoryService.loadDefaultCategories();
    print('✅ Categorías por defecto cargadas');
    
    runApp(const MyApp());
    
  } catch (e, stacktrace) {
    print('❌ ERROR: $e');
    print('Stacktrace: $stacktrace');
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Get.find<PreferencesService>();
    final isDarkMode = prefs.themeMode == 'dark';
    
    return GetMaterialApp(
      title: 'MoneyFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      locale: Locale(prefs.language),
      fallbackLocale: const Locale('es'),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Error al iniciar la app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    runApp(const MyApp());
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/views/screens/home_screen.dart';
import 'package:money_flow/views/screens/charts_screen.dart';
import 'package:money_flow/theme/colors.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🔄 Iniciando servicios...');
    
    // Inicializar servicios
    Get.put(CategoryService());
    Get.put(TransactionService());
    
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
    return GetMaterialApp(
      title: 'MoneyFlow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.danger,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
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
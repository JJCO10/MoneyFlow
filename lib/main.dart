import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/category_service.dart';
import 'package:money_flow/services/notification_service.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/shared_preferences_service.dart';
import 'package:money_flow/services/budget_service.dart';
import 'package:money_flow/services/csv_export_service.dart';
import 'package:money_flow/services/pdf_export_service.dart';
import 'package:money_flow/services/export_service.dart';
import 'package:money_flow/views/screens/home_screen.dart';
import 'package:money_flow/theme/app_theme.dart';
import 'package:money_flow/l10n/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🔄 Iniciando servicios...');
    
    // 1. Preferencias primero
    await Get.putAsync(() => PreferencesService().init());
    
    // 2. Controlador de traducciones
    Get.put(AppTranslationsController());
    print('✅ AppTranslationsController inicializado');
    
    // 3. Servicios de base de datos
    Get.put(CategoryService());
    Get.put(TransactionService());
    Get.put(BudgetService());
    
    // 4. Servicios de exportación
    Get.put(CsvExportService());
    Get.put(PdfExportService());
    Get.put(ExportService());

    // 🔥 5. Servicio de notificaciones
    await Get.putAsync(() => NotificationService().init());
    
    print('✅ Servicios inicializados');
    
    // Cargar categorías por defecto
    final categoryService = Get.find<CategoryService>();
    await categoryService.loadDefaultCategories();
    print('✅ Categorías por defecto cargadas');

    // 🔥 Solicitar permisos de notificación
    final notificationService = Get.find<NotificationService>();
    final hasPermission = await notificationService.requestPermissions();
    print('🔔 Permisos de notificación: $hasPermission');

    // 🔥 Programar resumen diario si tiene permiso
    if (hasPermission) {
      await notificationService.scheduleDailySummaryIfEnabled();
      print('📊 Resumen diario programado');
    }
    
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
    final translationsController = Get.find<AppTranslationsController>();
    final isDarkMode = prefs.themeMode == 'dark';
    
    // Cargar idioma guardado
    translationsController.currentLanguage.value = prefs.language;
    
    return GetMaterialApp(
      title: 'MoneyFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      locale: Locale(prefs.language),
      fallbackLocale: const Locale('es'),
      translations: AppTranslations(),
      // Usar el controlador para traducciones dinámicas
      initialBinding: BindingsBuilder(() {
        Get.put(AppTranslationsController());
      }),
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
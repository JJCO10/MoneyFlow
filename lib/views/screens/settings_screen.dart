import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';
import 'package:money_flow/controllers/home_controller.dart';
import 'package:money_flow/controllers/settings_controller.dart';
import 'package:money_flow/services/export_service.dart';
import 'package:money_flow/services/backup_service.dart';
import 'package:money_flow/utils/file_share_channel.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/l10n/translations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final exportService = Get.find<ExportService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textLight = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1);
    
    final selectedMonth = DateTime.now().obs;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.t),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ==================== APARIENCIA ====================
            _buildSection(
              title: 'appearance'.t,
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                Obx(() => SwitchListTile(
                  title: Text(
                    'dark_mode'.t,
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'dark_mode_subtitle'.t,
                    style: TextStyle(color: textSecondary),
                  ),
                  value: controller.isDarkMode.value,
                  onChanged: controller.toggleTheme,
                  activeColor: AppColors.primary,
                )),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ==================== IDIOMA ====================
            _buildSection(
              title: 'language'.t,
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedLanguage.value,
                  dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: 'select_language'.t,
                    labelStyle: TextStyle(color: textSecondary),
                    border: const OutlineInputBorder(),
                  ),
                  items: controller.languages.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang['code'],
                      child: Text(
                        lang['name']!,
                        style: TextStyle(color: textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeLanguage(value);
                    }
                  },
                )),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ==================== NOTIFICACIONES ====================
            _buildSection(
              title: 'Notificaciones',
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                ListTile(
                  leading: Icon(Icons.notifications, color: AppColors.primary),
                  title: Text(
                    'Recordatorios de presupuestos',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Recibir alertas cuando te acerques al límite',
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Obx(() => Switch(
                    value: controller.budgetAlertsEnabled.value,
                    onChanged: (value) {
                      controller.toggleBudgetAlerts(value);
                    },
                    activeColor: AppColors.primary,
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.alarm, color: AppColors.primary),
                  title: Text(
                    'Resumen diario',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Recibir un resumen de tus gastos cada día a las 9:00 PM',
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Obx(() => Switch(
                    value: controller.dailySummaryEnabled.value,
                    onChanged: (value) {
                      controller.toggleDailySummary(value);
                    },
                    activeColor: AppColors.primary,
                  )),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ==================== EXPORTAR DATOS ====================
            _buildSection(
              title: 'export_title'.t,
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                Obx(() => ListTile(
                  leading: Icon(Icons.calendar_month, color: AppColors.primary),
                  title: Text(
                    'select_month'.t,
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    DateFormat('MMMM yyyy').format(selectedMonth.value),
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedMonth.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDatePickerMode: DatePickerMode.year,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      selectedMonth.value = date;
                    }
                  },
                )),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: AppColors.primary),
                  title: Text(
                    'export_pdf'.t,
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'export_pdf_subtitle'.t,
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
                  onTap: () => exportService.exportToPDF(selectedMonth.value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.table_chart, color: AppColors.primary),
                  title: Text(
                    'export_csv'.t,
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'export_csv_subtitle'.t,
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
                  onTap: () => exportService.exportToCSV(selectedMonth.value),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================== BACKUP ====================
            _buildSection(
              title: 'Backup',
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                ListTile(
                  leading: Icon(Icons.backup, color: AppColors.primary),
                  title: Text(
                    'Exportar backup',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Guardar todos los datos en un archivo',
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
                  onTap: _exportBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.restore, color: AppColors.primary),
                  title: Text(
                    'Importar backup',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Restaurar datos desde un archivo',
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
                  onTap: _importBackup,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================== FEEDBACK HÁPTICO ====================
            _buildSection(
              title: 'Interacción',
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                Obx(() => SwitchListTile(
                  title: Text(
                    'Vibración al tocar',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Respuesta háptica en botones y acciones',
                    style: TextStyle(color: textSecondary),
                  ),
                  value: controller.hapticFeedbackEnabled.value,
                  onChanged: (value) {
                    controller.toggleHapticFeedback(value);
                  },
                  activeColor: AppColors.primary,
                )),
              ],
            ),

            const SizedBox(height: 16),
            
            // ==================== ACERCA DE ====================
            _buildSection(
              title: 'about'.t,
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: AppColors.primary),
                  title: Text(
                    'version'.t,
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    '1.0.0',
                    style: TextStyle(color: textSecondary),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.favorite, color: AppColors.primary),
                  title: Text(
                    'app_name'.t,
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'app_description'.t,
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required Color cardBg,
    required Color shadowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // ==================== MÉTODOS DE BACKUP ====================
  void _exportBackup() async {
    final backupService = Get.find<BackupService>();
    final file = await backupService.exportBackup();
    
    if (file != null) {
      Get.snackbar(
        'Éxito',
        'Backup exportado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // Compartir archivo
      await FileShareChannel.shareFile(file.path, 'application/json');
    } else {
      Get.snackbar(
        'Error',
        'No se pudo exportar el backup',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // 🔥 MÉTODO ACTUALIZADO CON FILE_SELECTOR
  void _importBackup() async {
    try {
      // Seleccionar archivo usando file_selector
      final typeGroup = XTypeGroup(
        label: 'JSON',
        extensions: ['json'],
        mimeTypes: ['application/json'],
      );
      
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      
      if (file == null) {
        print('❌ Selección de archivo cancelada');
        return;
      }
      
      final backupService = Get.find<BackupService>();
      
      // Verificar información del backup
      final info = await backupService.getBackupInfo(File(file.path));
      if (info == null) {
        Get.snackbar(
          'Error',
          'El archivo no es un backup válido',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      // Mostrar información antes de importar
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Información del Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Versión: ${info['version']}'),
              Text('Fecha: ${info['exportDate']}'),
              const SizedBox(height: 8),
              Text('Categorías: ${info['categories']}'),
              Text('Transacciones: ${info['transactions']}'),
              Text('Presupuestos: ${info['budgets']}'),
              const SizedBox(height: 16),
              const Text(
                '¿Deseas importar estos datos?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Importar'),
            ),
          ],
        ),
      );
      
      if (confirm != true) {
        print('❌ Importación cancelada por el usuario');
        return;
      }
      
      // Importar datos
      final success = await backupService.importBackup(File(file.path));
      
      if (success) {
        Get.snackbar(
          'Éxito',
          'Backup importado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Recargar datos
        final homeController = Get.find<HomeController>();
        await homeController.loadData();
        
      } else {
        Get.snackbar(
          'Error',
          'No se pudo importar el backup',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al importar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
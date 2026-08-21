import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/controllers/settings_controller.dart';
import 'package:money_flow/services/export_service.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:intl/intl.dart';

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
    
    // Selección de mes para exportar
    final selectedMonth = DateTime.now().obs;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tema
            _buildSection(
              title: 'Apariencia',
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                Obx(() => SwitchListTile(
                  title: Text(
                    'Modo Oscuro',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Cambiar tema de la app',
                    style: TextStyle(color: textSecondary),
                  ),
                  value: controller.isDarkMode.value,
                  onChanged: controller.toggleTheme,
                  activeColor: AppColors.primary,
                )),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Moneda
            _buildSection(
              title: 'Moneda',
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedCurrency.value,
                  dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Moneda predeterminada',
                    labelStyle: TextStyle(color: textSecondary),
                    border: const OutlineInputBorder(),
                  ),
                  items: controller.currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(
                        currency,
                        style: TextStyle(color: textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeCurrency(value);
                    }
                  },
                )),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Idioma
            _buildSection(
              title: 'Idioma',
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedLanguage.value,
                  dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Idioma',
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
            
            // Exportar datos
            _buildSection(
              title: 'Exportar Datos',
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                // Selector de mes
                Obx(() => ListTile(
                  leading: Icon(Icons.calendar_month, color: AppColors.primary),
                  title: Text(
                    'Seleccionar Mes',
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
                    'Exportar a PDF',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Reporte mensual con resumen',
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
                  onTap: () => exportService.exportToPDF(selectedMonth.value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.table_chart, color: AppColors.primary),
                  title: Text(
                    'Exportar a Excel (CSV)',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Datos en formato tabular',
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
                  onTap: () => exportService.exportToCSV(selectedMonth.value),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Acerca de
            _buildSection(
              title: 'Acerca de',
              cardBg: cardBg,
              shadowColor: shadowColor,
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: AppColors.primary),
                  title: Text(
                    'Versión',
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
                    'MoneyFlow',
                    style: TextStyle(color: textPrimary),
                  ),
                  subtitle: Text(
                    'Tu app financiera personal',
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
}
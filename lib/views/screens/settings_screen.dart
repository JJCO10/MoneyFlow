import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/theme/app_theme.dart';
import 'package:money_flow/theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          _buildSection('Preferencias', [
            _buildListTile(
              'Tema Oscuro',
              Icons.dark_mode,
              onTap: () {
                // Implementar cambio de tema
                Get.snackbar('Info', 'Función en desarrollo');
              },
            ),
            _buildListTile(
              'Moneda Predeterminada',
              Icons.attach_money,
              subtitle: 'USD \$',
              onTap: () {
                Get.snackbar('Info', 'Función en desarrollo');
              },
            ),
          ]),
          _buildSection('Datos', [
            _buildListTile(
              'Gestionar Categorías',
              Icons.category,
              onTap: () => Get.toNamed('/categories'),
            ),
            _buildListTile(
              'Exportar Datos',
              Icons.export_rounded,
              onTap: () {
                Get.snackbar('Info', 'Función en desarrollo');
              },
            ),
          ]),
          _buildSection('Acerca de', [
            _buildListTile(
              'Versión',
              Icons.info,
              subtitle: '1.0.0',
              onTap: null,
            ),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
  
  Widget _buildListTile(String title, IconData icon, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
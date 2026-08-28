import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/widgets/main_scaffold.dart';
import 'package:money_flow/l10n/translations.dart';
import 'package:money_flow/services/shared_preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.attach_money,
      title: 'Bienvenido a MoneyFlow',
      description: 'Gestiona tus finanzas personales de manera fácil y rápida',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.add_chart,
      title: 'Registra tus movimientos',
      description: 'Añade ingresos y gastos con solo un toque. Categoriza cada transacción para mejor control.',
      color: AppColors.secondary,
    ),
    OnboardingPage(
      icon: Icons.pie_chart,
      title: 'Visualiza tus finanzas',
      description: 'Gráficos interactivos y calendario para entender mejor tus hábitos financieros.',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.notifications,
      title: 'Mantente al día',
      description: 'Recibe alertas de presupuestos y resúmenes diarios para no perder el control.',
      color: AppColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==================== PÁGINAS ====================
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: _pages.map((page) {
              return _buildPage(page);
            }).toList(),
          ),
          
          // ==================== INDICADORES ====================
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
          
          // ==================== BOTÓN SIGUIENTE/COMENZAR ====================
          Positioned(
            bottom: 40,
            right: 24,
            child: _buildNextButton(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return Container(
      color: isDark ? AppColors.darkBackground : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== ICONO =====
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                page.icon,
                size: 80,
                color: page.color,
              ),
            ),
            const SizedBox(height: 40),
            
            // ===== TÍTULO =====
            Text(
              page.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // ===== DESCRIPCIÓN =====
            Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  Widget _buildNextButton() {
    final isLast = _currentPage == _pages.length - 1;
    
    return ElevatedButton(
      onPressed: () {
        if (isLast) {
          _completeOnboarding();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 2,
      ),
      child: Text(
        isLast ? 'Comenzar' : 'Siguiente',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  void _completeOnboarding() {
    // Guardar que el onboarding se completó
    final prefs = Get.find<PreferencesService>();
    prefs.onboardingCompleted = true;
    
    // Navegar a la pantalla principal
    Get.offAll(() => const MainScaffold());
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
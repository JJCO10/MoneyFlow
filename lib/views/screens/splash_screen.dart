import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_flow/theme/colors.dart';
import 'package:money_flow/views/screens/onboarding_screen.dart';
import 'package:money_flow/views/widgets/main_scaffold.dart';
import 'package:money_flow/services/shared_preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final prefs = Get.find<PreferencesService>();
    
    // 🔥 SI ES LA PRIMERA VEZ, MOSTRAR ONBOARDING
    if (prefs.onboardingCompleted) {
      Get.offAll(() => const MainScaffold());
    } else {
      Get.offAll(() => const OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'MoneyFlow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu app financiera personal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
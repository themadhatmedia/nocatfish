import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_text.dart';
import 'home/home_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authController = Get.find<AuthController>();

    print('\n=== SPLASH SCREEN AUTH CHECK ===');
    print('Checking authentication status...');

    final isLoggedIn = await authController.checkAuth();

    print('Is Logged In: $isLoggedIn');
    print('Token: ${authController.token?.substring(0, 20) ?? "null"}...');
    print('User: ${authController.user}');
    print('=== END AUTH CHECK ===\n');

    if (!mounted) return;

    if (isLoggedIn) {
      print('Navigating to HomeScreen');
      Get.offAll(() => const HomeScreen());
    } else {
      print('Navigating to WelcomeScreen');
      Get.offAll(() => const WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a2332),
              Color(0xFF2a3342),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandOrange.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2000.ms, color: AppTheme.brandOrange.withOpacity(0.3)).scale(duration: 1500.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), curve: Curves.easeInOut),
              const SizedBox(height: 40),
              GradientText(
                text: 'Catfish Scan',
                gradient: AppTheme.primaryGradient,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                'AI-Powered Photo Verification',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 0.8,
                      fontSize: 15,
                    ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 60),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.brandOrange,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat()).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

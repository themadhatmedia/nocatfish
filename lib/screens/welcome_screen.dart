import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_text.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.brandOrange.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                duration: 3000.ms,
                color: AppTheme.brandOrange.withOpacity(0.1),
              ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.lightOrange.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                duration: 4000.ms,
                color: AppTheme.brandOrange.withOpacity(0.1),
              ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // const Spacer(flex: 2),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.brandOrange.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2000.ms, color: AppTheme.brandOrange.withOpacity(0.3)),
                    const SizedBox(height: 20.0),
                    GradientText(
                      text: 'Welcome to\nCatfish Scan',
                      gradient: AppTheme.primaryGradient,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            height: 1.2,
                          ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                    SizedBox(height: 15.0),
                    Text(
                      'Detect photo manipulations and AI-generated images with advanced verification technology',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                    SizedBox(height: 30.0),
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      blur: 15,
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            Icons.privacy_tip_outlined,
                            'Privacy First',
                            'Your photos are never stored permanently',
                          ),
                          const SizedBox(height: 15.0),
                          _buildFeatureItem(
                            Icons.speed,
                            'Fast Analysis',
                            'Get results in seconds with AI detection',
                          ),
                          const SizedBox(height: 15.0),
                          _buildFeatureItem(
                            Icons.verified_user_outlined,
                            'Accurate Results',
                            'Advanced algorithms detect manipulations',
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                    // const Spacer(flex: 2),
                    SizedBox(height: 20.0),
                    GradientButton(
                      text: 'Get Started',
                      onPressed: () {
                        Get.to(() => const RegisterScreen());
                      },
                      gradient: AppTheme.primaryGradient,
                      icon: Icons.arrow_forward,
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                    // const SizedBox(height: 15.0),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const LoginScreen());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          GradientText(
                            text: 'Sign In',
                            gradient: AppTheme.primaryGradient,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
                    // const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../screens/packages/packages_screen.dart';
import '../services/analytics_service.dart';
import '../utils/app_theme.dart';
import 'glass_container.dart';
import 'gradient_button.dart';

class LowScansPopup extends StatelessWidget {
  final int remainingScans;

  const LowScansPopup({
    super.key,
    required this.remainingScans,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        blur: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.darkOrange.withOpacity(0.3),
                    AppTheme.brandOrange.withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.brandOrange.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 48,
                color: AppTheme.brandOrange,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOut).shake(duration: 500.ms, delay: 200.ms),
            const SizedBox(height: 24),
            Text(
              'Low on Coins!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            Text(
              remainingScans > 0 ? 'You only have $remainingScans ${remainingScans == 1 ? 'coin' : 'coins'} remaining.' : 'You have no coins remaining.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Get more coins to continue detecting catfish photos.',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Buy Coins',
              onPressed: () async {
                final analytics = Get.find<AnalyticsService>();
                await analytics.logPackagesScreenViewed();
                Get.back();
                Get.to(() => const PackagesScreen());
              },
              gradient: AppTheme.primaryGradient,
              icon: Icons.shopping_bag_outlined,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Maybe Later',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, int remainingScans) async {
    final analytics = Get.find<AnalyticsService>();

    if (remainingScans == 0) {
      await analytics.logNoScansError();
    } else {
      await analytics.logLowScansWarning(remainingScans: remainingScans);
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => LowScansPopup(remainingScans: remainingScans),
    );
  }
}

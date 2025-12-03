import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../controllers/analysis_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_text.dart';
import '../results/result_detail_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final int consentLogId;

  const AnalysisScreen({
    super.key,
    required this.consentLogId,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late final AnalysisController analysisController;
  final dashboardController = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    analysisController = Get.put(AnalysisController());
    analysisController.startAnalysis(widget.consentLogId);

    ever(analysisController.statusRx, (status) {
      if (status != null && status.isCompleted && mounted) {
        dashboardController.dashboard?.recentResults.clear();
        dashboardController.refresh();
        Get.off(
          () => ResultDetailScreen(
            scanResultId: status.scanResultId!,
            goto: 'direct_home',
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('consentLogId: ${widget.consentLogId}');
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a2332),
              Color(0xFF2a3342),
              Color(0xFF2a3342),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              final currentStep = analysisController.currentStep;
              final progress = analysisController.progress;
              final error = analysisController.error;

              if (error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.darkOrange,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Analysis Failed',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkOrange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.brandOrange.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                            duration: 2000.ms,
                            color: Colors.white.withOpacity(0.2),
                          ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.brandOrange.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          size: 60,
                          color: Colors.white,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat()).rotate(
                            duration: 3000.ms,
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  GradientText(
                    text: 'Analyzing Photo',
                    gradient: AppTheme.primaryGradient,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 16),
                  Text(
                    currentStep,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ).animate(key: ValueKey(currentStep)).fadeIn(duration: 400.ms),
                  const SizedBox(height: 40),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    blur: 15,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progress',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.brandOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    blur: 10,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.successGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lock_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your photo is being analyzed securely and will not be stored permanently',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    analysisController.stopPolling();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/dashboard_controller.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/shimmer_placeholder.dart';
import 'result_detail_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final dashboardController = Get.find<DashboardController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.dashboard?.recentResults.clear();
      dashboardController.refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GradientText(
                      text: 'Results History',
                      gradient: AppTheme.primaryGradient,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      onPressed: () {
                        dashboardController.dashboard?.recentResults.clear();
                        dashboardController.refresh();
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              ),
              Expanded(
                child: Obx(() {
                  if ((dashboardController.isLoading && dashboardController.recentResults == null) || (dashboardController.dashboard!.recentResults.isEmpty)) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: 5,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ShimmerPlaceholder(
                          width: MediaQuery.of(context).size.width,
                          height: 120,
                          borderRadius: 16,
                        ),
                      ),
                    );
                  }

                  final results = dashboardController.recentResults ?? [];

                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient.scale(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history_outlined,
                              size: 60,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No Results Yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload a photo to see your first result',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      dashboardController.dashboard?.recentResults.clear();
                      dashboardController.refresh();
                    },
                    backgroundColor: const Color(0xFF2a3342),
                    color: AppTheme.brandOrange,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        print('result: $result');
                        return _buildResultCard(result, index).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(result, int index) {
    final score = result.catfishScore;
    final level = result.catfishLevel;
    final analysisCompletedAt = result.analysisCompletedAt;

    Color levelColor;
    IconData levelIcon;

    if (score >= 7) {
      levelColor = AppTheme.darkOrange;
      levelIcon = Icons.warning_rounded;
    } else if (score >= 4) {
      levelColor = const Color(0xFFED8F03);
      levelIcon = Icons.info_outline;
    } else {
      levelColor = AppTheme.brandOrange;
      levelIcon = Icons.verified_outlined;
    }

    // final minutes = timeRemaining ~/ 60;
    // final seconds = timeRemaining % 60;
    final timeagostr = timeago.format(DateTime.parse(analysisCompletedAt.toString()));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Get.to(() => ResultDetailScreen(scanResultId: result.id));
        },
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          blur: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        // '${minutes}m ${seconds}s',
                        timeagostr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                levelColor,
                                levelColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            levelIcon,
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
                                level,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Score: $score/10',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

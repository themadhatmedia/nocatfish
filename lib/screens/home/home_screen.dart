import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:nocatfish_app/screens/packages/packages_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/api_response.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_text.dart';
import '../profile/profile_screen.dart';
import '../results/result_detail_screen.dart';
import '../results/results_screen.dart';
import '../upload/upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ResultsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkNavy.withOpacity(0.95),
            AppTheme.darkNavy,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.history_rounded, 'Results', 1),
              _buildNavItem(Icons.person_rounded, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final dashboardController = Get.find<DashboardController>();
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.ddashboard(null);
      dashboardController.loadDashboard();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            dashboardController.refresh();
          },
          backgroundColor: AppTheme.darkNavy,
          color: AppTheme.brandOrange,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              if (dashboardController.isLoading || dashboardController.dashboard == null) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.brandOrange,
                    ),
                  ),
                );
              }

              final userName = authController.user?['name'] ?? 'User';
              final stats = dashboardController.statistics;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: Text(
                              'Hello, $userName',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 20.0,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to verify photos?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => PackagesScreen());
                        },
                        child: Container(
                          width: 55,
                          height: 55,
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(16),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: AppTheme.brandOrange.withOpacity(0.3),
                          //       blurRadius: 15,
                          //       spreadRadius: 2,
                          //     ),
                          //   ],
                          // ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            // gradient: LinearGradient(
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            //   // colors: [
                            //   //   Color(0xFFFFD54F), // light golden
                            //   //   Color(0xFFF9A825), // dark golden
                            //   // ],
                            //   colors: [Colors.grey.shade400, Colors.grey.shade500],
                            // ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                                // color: Colors.black.withOpacity(0.2),
                                color: AppTheme.brandOrange.withOpacity(0.3),
                              ),
                            ],
                          ),
                          // child: Image.asset(
                          //   'assets/images/logo.png',
                          //   fit: BoxFit.contain,
                          // ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dashboardController.dashboard!.tokensBalance.toString(),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                // const SizedBox(height: 2),
                                const Text(
                                  'Coins',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                              duration: 2000.ms,
                              color: AppTheme.brandOrange.withOpacity(0.3),
                            ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 40),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    blur: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.successGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.security,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Privacy Protected',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'No data stored permanently',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 20),
                        if (stats != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                '${stats.remainingUploads}',
                                'Remaining\nToday',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white24,
                              ),
                              _buildStatItem(
                                '${stats.totalUploadsThisWeek}',
                                'Analyzed\nThis Week',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white24,
                              ),
                              _buildStatItem(
                                '${stats.activeResults}',
                                'Active\nResults',
                              ),
                            ],
                          )
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: AppTheme.brandOrange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 40),
                  GradientButton(
                    text: 'Upload & Analyze Photo',
                    onPressed: () {
                      Get.to(() => const UploadScreen());
                      // var user = StorageService().getUser()!;
                      // print('id: ${user['id']}');
                      // print('name: ${user['name']}');
                      // print('email: ${user['email']}');
                    },
                    gradient: AppTheme.primaryGradient,
                    height: 64,
                    icon: Icons.camera_alt_outlined,
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 30),
                  if (dashboardController.recentResults != null && dashboardController.recentResults!.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GradientText(
                          text: 'Recent Results',
                          gradient: AppTheme.primaryGradient,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                    const SizedBox(height: 20),
                    ...dashboardController.recentResults!.take(3).toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final result = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildRecentResultCard(context, result),
                      ).animate().fadeIn(delay: (600 + (index * 100)).ms, duration: 600.ms).slideX(begin: -0.2, end: 0);
                    }),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                        homeState?.setState(() {
                          homeState._currentIndex = 1;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        side: BorderSide(color: AppTheme.brandOrange, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GradientText(
                            text: 'View All Results',
                            gradient: AppTheme.primaryGradient,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: AppTheme.brandOrange,
                            size: 20,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                    const SizedBox(height: 30),
                  ],
                  GradientText(
                    text: 'How It Works',
                    gradient: AppTheme.primaryGradient,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                  const SizedBox(height: 20),
                  _buildHowItWorksStep(
                    1,
                    'Upload Photo',
                    'Take or choose a photo to analyze',
                    Icons.cloud_upload_outlined,
                  ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  _buildHowItWorksStep(
                    2,
                    'AI Analysis',
                    'Our AI detects manipulations and edits',
                    Icons.psychology_outlined,
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  _buildHowItWorksStep(
                    3,
                    'Get Results',
                    'View detailed analysis and score',
                    Icons.verified_outlined,
                  ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 40),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        GradientText(
          text: value,
          gradient: AppTheme.primaryGradient,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksStep(int step, String title, String description, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      blur: 10,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppTheme.successGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Step $step',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
      ),
    );
  }

  Widget _buildRecentResultCard(BuildContext context, RecentResult result) {
    // final minutes = result.timeRemainingSeconds ~/ 60;
    final levelColor = _getResultLevelColor(result.catfishLevel);
    final timeagostr = timeago.format(DateTime.parse(result.analysisCompletedAt.toString()));

    return GestureDetector(
      onTap: () {
        Get.to(
          () => ResultDetailScreen(
            scanResultId: result.id,
            goto: 'home_screen',
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        blur: 15,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [levelColor, levelColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${result.catfishScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.catfishLevel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white.withOpacity(0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        // '${minutes}m ${seconds}s',
                        timeagostr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                      // Text(
                      //   'Expires in ${minutes}m',
                      //   style: TextStyle(
                      //     color: Colors.white.withOpacity(0.6),
                      //     fontSize: 13,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.brandOrange,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Color _getResultLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'severe catfish':
      case 'high':
        return AppTheme.darkOrange;
      case 'moderate catfish':
      case 'medium':
        return const Color(0xFFED8F03);
      case 'low catfish':
      case 'low':
        return const Color(0xFFFFB75E);
      case 'authentic':
      case 'minimal':
        return const Color(0xFF4caf50);
      default:
        return AppTheme.brandOrange;
    }
  }
}

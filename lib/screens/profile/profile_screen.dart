import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_text.dart';
import '../packages/packages_screen.dart';
import '../welcome_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final dashboardController = Get.find<DashboardController>();

    return Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() {
            final user = authController.user;
            final userName = user?['name'] ?? 'User';
            final userEmail = user?['email'] ?? 'email@example.com';
            final stats = dashboardController.statistics;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GradientText(
                      text: 'Profile',
                      gradient: AppTheme.primaryGradient,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(height: 40),
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  blur: 15,
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.brandOrange.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withOpacity(0.3),
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () {
                          Get.to(() => const EditProfileScreen());
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          side: BorderSide(color: AppTheme.brandOrange, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppTheme.brandOrange,
                          size: 18,
                        ),
                        label: GradientText(
                          text: 'Edit Profile',
                          gradient: AppTheme.primaryGradient,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale(delay: 200.ms),
                const SizedBox(height: 30),
                if (stats != null) ...[
                  GradientText(
                    text: 'Your Statistics',
                    gradient: AppTheme.primaryGradient,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '${stats.totalUploadsToday}',
                          'Uploads\nToday',
                          Icons.cloud_upload_outlined,
                          AppTheme.primaryGradient,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          '${stats.totalUploadsThisWeek}',
                          'This\nWeek',
                          Icons.calendar_today_outlined,
                          AppTheme.accentGradient,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '${stats.remainingUploads}',
                          'Remaining\nToday',
                          Icons.hourglass_empty_outlined,
                          AppTheme.successGradient,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          '${stats.maxDailyUploads}',
                          'Daily\nLimit',
                          Icons.settings_outlined,
                          AppTheme.warningGradient,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 30),
                ],
                GradientText(
                  text: 'Settings',
                  gradient: AppTheme.primaryGradient,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                const SizedBox(height: 20),
                GlassContainer(
                  padding: const EdgeInsets.all(4),
                  blur: 15,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => Get.to(() => const PackagesScreen()),
                        child: _buildSettingItem(
                          icon: Icons.attach_money,
                          title: 'Buy Coins',
                          subtitle: 'View packages',
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.white24,
                        height: 1,
                      ),
                      _buildSettingItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: themeController.isDarkMode,
                          onChanged: (value) => themeController.toggleTheme(),
                          activeColor: AppTheme.brandOrange,
                        ),
                      ),
                      // const Divider(color: Colors.white24, height: 1),
                      // _buildSettingItem(
                      //   icon: Icons.notifications_outlined,
                      //   title: 'Notifications',
                      //   trailing: Switch(
                      //     value: true,
                      //     onChanged: (value) {},
                      //     activeColor: AppTheme.brandOrange,
                      //   ),
                      // ),
                      // const Divider(color: Colors.white24, height: 1),
                      // _buildSettingItem(
                      //   icon: Icons.language_outlined,
                      //   title: 'Language',
                      //   subtitle: 'English',
                      //   trailing: const Icon(
                      //     Icons.arrow_forward_ios,
                      //     color: Colors.white54,
                      //     size: 16,
                      //   ),
                      // ),
                    ],
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 30),
                GradientText(
                  text: 'About',
                  gradient: AppTheme.primaryGradient,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
                const SizedBox(height: 20),
                GlassContainer(
                  padding: const EdgeInsets.all(4),
                  blur: 15,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final url = Uri.parse(AppTheme.privacyPolicy);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: _buildSettingItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      GestureDetector(
                        onTap: () async {
                          final url = Uri.parse(AppTheme.terms);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: _buildSettingItem(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      ),
                      // const Divider(color: Colors.white24, height: 1),
                      // _buildSettingItem(
                      //   icon: Icons.help_outline,
                      //   title: 'Help & Support',
                      //   trailing: const Icon(
                      //     Icons.arrow_forward_ios,
                      //     color: Colors.white54,
                      //     size: 16,
                      //   ),
                      // ),
                      const Divider(color: Colors.white24, height: 1),
                      _buildSettingItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'Version 1.0.0',
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1100.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 30),
                GradientButton(
                  text: 'Logout',
                  onPressed: () => _handleLogout(authController),
                  gradient: AppTheme.dangerGradient,
                  height: 56,
                  icon: Icons.logout,
                ).animate().fadeIn(delay: 1200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 40),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Gradient gradient) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      blur: 15,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
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
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient.scale(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Future<void> _handleLogout(AuthController authController) async {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2a3342),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();

              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.brandOrange,
                  ),
                ),
                barrierDismissible: false,
              );

              await authController.logout();

              Get.back();

              Get.offAll(() => const WelcomeScreen());
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.darkOrange),
            ),
          ),
        ],
      ),
    );
  }
}

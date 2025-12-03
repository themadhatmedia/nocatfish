import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_text.dart';
import '../welcome_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _isLoading = false.obs;
  final _isPasswordSectionExpanded = false.obs;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final user = authController.user;
    _nameController.text = user?['name'] ?? '';
    _emailController.text = user?['email'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    GradientText(
                      text: 'Edit Profile',
                      gradient: AppTheme.primaryGradient,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          blur: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Basic Information',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              CustomTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  if (value.length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!GetUtils.isEmail(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningGradient.colors.first.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.warningGradient.colors.first.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppTheme.warningGradient.colors.first,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Changing your email will require re-authentication',
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
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 24),
                        Obx(() => GlassContainer(
                              padding: const EdgeInsets.all(24),
                              blur: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _isPasswordSectionExpanded.value = !_isPasswordSectionExpanded.value;
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.dangerGradient,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.lock_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Change Password',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          _isPasswordSectionExpanded.value ? Icons.expand_less : Icons.expand_more,
                                          color: Colors.white70,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isPasswordSectionExpanded.value) ...[
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.dangerGradient.colors.first.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.dangerGradient.colors.first.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_outlined,
                                            color: AppTheme.darkOrange,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'You will be logged out after changing your password',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _currentPasswordController,
                                      label: 'Current Password',
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                      validator: (value) {
                                        if (_newPasswordController.text.isNotEmpty && (value == null || value.isEmpty)) {
                                          return 'Current password is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _newPasswordController,
                                      label: 'New Password',
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                      validator: (value) {
                                        if (_currentPasswordController.text.isNotEmpty) {
                                          if (value == null || value.isEmpty) {
                                            return 'New password is required';
                                          }
                                          if (value.length < 8) {
                                            return 'Password must be at least 8 characters';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _confirmPasswordController,
                                      label: 'Confirm New Password',
                                      prefixIcon: Icons.lock_outline,
                                      isPassword: true,
                                      validator: (value) {
                                        if (_newPasswordController.text.isNotEmpty) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value != _newPasswordController.text) {
                                            return 'Passwords do not match';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0)),
                        const SizedBox(height: 32),
                        Obx(
                          () => GradientButton(
                            text: _isLoading.value ? 'Updating...' : 'Save Changes',
                            onPressed: _isLoading.value ? () {} : _handleUpdateProfile,
                            gradient: AppTheme.primaryGradient,
                            height: 56,
                            icon: Icons.check,
                          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = Get.find<AuthController>();
    final currentUser = authController.user;
    final currentEmail = currentUser?['email'] ?? '';
    final newEmail = _emailController.text.trim();

    final isChangingEmail = newEmail != currentEmail;
    final isChangingPassword = _currentPasswordController.text.isNotEmpty;

    if (isChangingEmail || isChangingPassword) {
      final confirmed = await _showConfirmationDialog(
        isChangingEmail: isChangingEmail,
        isChangingPassword: isChangingPassword,
      );

      if (!confirmed) return;
    }

    _isLoading.value = true;

    try {
      final apiService = ApiService();
      final token = authController.token;

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication token not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await apiService.updateUser(
        token: token,
        name: _nameController.text.trim(),
        email: newEmail,
        currentPassword: _currentPasswordController.text.isNotEmpty ? _currentPasswordController.text : null,
        password: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
        passwordConfirmation: _confirmPasswordController.text.isNotEmpty ? _confirmPasswordController.text : null,
      );

      _isLoading.value = false;

      if (response.success && response.data != null) {
        Get.snackbar(
          'Success',
          response.message ?? 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        if (isChangingEmail || isChangingPassword) {
          await Future.delayed(const Duration(seconds: 2));
          await authController.logout();
          Get.offAll(() => const WelcomeScreen());

          Get.snackbar(
            'Please Login Again',
            isChangingPassword ? 'Your password has been changed. Please login with your new password.' : 'Your email has been changed. Please login again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        } else {
          await Future.delayed(const Duration(seconds: 3));
          authController.updateUserData(response.data!.toJson());
          Navigator.of(Get.context!).pop();
        }
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.red,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> _showConfirmationDialog({
    required bool isChangingEmail,
    required bool isChangingPassword,
  }) async {
    String title = '';
    String content = '';

    if (isChangingPassword && isChangingEmail) {
      title = 'Change Password & Email?';
      content = 'You will be logged out after these changes. You\'ll need to login again with your new credentials.';
    } else if (isChangingPassword) {
      title = 'Change Password?';
      content = 'You will be logged out after changing your password. You\'ll need to login again with your new password.';
    } else if (isChangingEmail) {
      title = 'Change Email?';
      content = 'You will be logged out after changing your email. You\'ll need to login again.';
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF2a3342),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.darkOrange,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.darkOrange.withOpacity(0.1),
            ),
            child: Text(
              'Continue',
              style: TextStyle(color: AppTheme.darkOrange),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

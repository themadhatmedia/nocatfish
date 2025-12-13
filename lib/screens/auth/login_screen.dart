import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_text.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _countryCode = '+1';
  String _fullPhoneNumber = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authController = Get.find<AuthController>();
    final response = await authController.sendOtp(
      phoneNumber: _fullPhoneNumber,
      countryCode: _countryCode,
    );

    setState(() => _isLoading = false);

    if (response.success && mounted) {
      Get.to(() => OtpVerificationScreen(
            phoneNumber: _fullPhoneNumber,
            countryCode: _countryCode,
            isRegistration: false,
          ));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.errorMessage),
          backgroundColor: AppTheme.darkOrange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 40),
                    GradientText(
                      text: 'Welcome\nBack',
                      gradient: AppTheme.primaryGradient,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                    ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    Text(
                      'Login to continue protecting yourself',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 60),
                    GlassContainer(
                      padding: const EdgeInsets.all(15.0),
                      blur: 15,
                      child: Column(
                        children: [
                          IntlPhoneField(
                            controller: _phoneController,
                            // disableLengthCheck: true,
                            // autovalidateMode: AutovalidateMode.onUserInteraction,
                            // maxLengthEnforcement: MaxLengthEnforcement.none,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.brandOrange,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.darkOrange,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.darkOrange,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            dropdownTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            // dropdownDecoration: BoxDecoration(
                            //   color: AppTheme.cardColor,
                            //   borderRadius: BorderRadius.circular(12),
                            // ),
                            initialCountryCode: 'US',
                            onChanged: (phone) {
                              setState(() {
                                _countryCode = phone.countryCode;
                                _fullPhoneNumber = phone.number;
                              });
                            },
                            validator: (phone) {
                              if (phone == null || phone.number.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!phone.isValidNumber()) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          GradientButton(
                            text: 'Send OTP',
                            onPressed: _handleLogin,
                            gradient: AppTheme.primaryGradient,
                            isLoading: _isLoading,
                            icon: Icons.message_outlined,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.off(() => const RegisterScreen());
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: AppTheme.brandOrange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

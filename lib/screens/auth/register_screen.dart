import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../controllers/auth_controller.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _countryCode = '+1';
  String _fullPhoneNumber = '';
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and privacy policy'),
          backgroundColor: AppTheme.darkOrange,
        ),
      );
      return;
    }

    // Get.to(
    //   () => OtpVerificationScreen(
    //     phoneNumber: _fullPhoneNumber,
    //     countryCode: _countryCode,
    //     name: _nameController.text,
    //     isRegistration: true,
    //   ),
    // );

    setState(() => _isLoading = true);

    final authController = Get.find<AuthController>();
    final response = await authController.sendOtp(
      phoneNumber: _fullPhoneNumber,
      countryCode: _countryCode,
    );

    setState(() => _isLoading = false);

    if (response.success && mounted) {
      Get.to(
        () => OtpVerificationScreen(
          phoneNumber: _fullPhoneNumber,
          countryCode: _countryCode,
          name: _nameController.text,
          isRegistration: true,
        ),
      );
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
                      text: 'Create\nAccount',
                      gradient: AppTheme.primaryGradient,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                    ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    Text(
                      'Sign up to start detecting catfish photos',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 50),
                    GlassContainer(
                      padding: const EdgeInsets.all(15.0),
                      blur: 15,
                      child: Column(
                        children: [
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
                          const SizedBox(height: 20),
                          IntlPhoneField(
                            controller: _phoneController,
                            // disableLengthCheck: true,
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
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptedTerms,
                                onChanged: (value) {
                                  setState(() => _acceptedTerms = value ?? false);
                                },
                                fillColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return AppTheme.brandOrange;
                                    }
                                    return Colors.white.withOpacity(0.2);
                                  },
                                ),
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // Expanded(
                              //   child: Text.rich(
                              //     TextSpan(
                              //       text: 'I accept the ',
                              //       style: const TextStyle(
                              //         color: Colors.white70,
                              //         fontSize: 13,
                              //       ),
                              //       children: [
                              //         TextSpan(
                              //           text: 'Terms of Service',
                              //           style: TextStyle(
                              //             color: AppTheme.brandOrange,
                              //             fontWeight: FontWeight.w600,
                              //           ),
                              //         ),
                              //         const TextSpan(text: ' and '),
                              //         TextSpan(
                              //           text: 'Privacy Policy',
                              //           style: TextStyle(
                              //             color: AppTheme.brandOrange,
                              //             fontWeight: FontWeight.w600,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I accept the ',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Services',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            print("Terms of Service clicked");
                                            final url = Uri.parse(AppTheme.terms);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            }
                                          },
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: const TextStyle(
                                          color: Colors.blue, // link color
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            print("Privacy Policy clicked");
                                            final url = Uri.parse(AppTheme.privacyPolicy);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            }
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          GradientButton(
                            text: 'Send OTP',
                            onPressed: _handleRegister,
                            gradient: AppTheme.primaryGradient,
                            isLoading: _isLoading,
                            icon: Icons.message_outlined,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.off(() => const LoginScreen());
                                },
                                child: Text(
                                  'Login',
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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_text.dart';
import '../../controllers/auth_controller.dart';
import '../home/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final String? name;
  final bool isRegistration;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    this.name,
    this.isRegistration = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCountdown--);
      return _resendCountdown > 0;
    });
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppTheme.darkOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authController = Get.find<AuthController>();
    final response = widget.isRegistration
        ? await authController.verifyOtpAndRegister(
            name: widget.name!,
            phoneNumber: widget.phoneNumber,
            countryCode: widget.countryCode,
            otp: _otpController.text,
          )
        : await authController.verifyOtpAndLogin(
            phoneNumber: widget.phoneNumber,
            countryCode: widget.countryCode,
            otp: _otpController.text,
          );

    setState(() => _isLoading = false);

    if (response.success && mounted) {
      Get.offAll(() => const HomeScreen());
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.errorMessage),
          backgroundColor: AppTheme.darkOrange,
        ),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() => _isResending = true);

    final authController = Get.find<AuthController>();
    final response = await authController.sendOtp(
      phoneNumber: widget.phoneNumber,
      countryCode: widget.countryCode,
    );

    setState(() => _isResending = false);

    if (response.success && mounted) {
      _startResendCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: AppTheme.primaryColor,
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
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.brandOrange,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppTheme.brandOrange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.brandOrange,
          width: 2,
        ),
      ),
    );

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
                    text: 'Verify OTP',
                    gradient: AppTheme.primaryGradient,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                  ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  Text(
                    'Enter the 6-digit code sent to\n${widget.countryCode} ${widget.phoneNumber}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 60),
                  GlassContainer(
                    padding: const EdgeInsets.all(15.0),
                    blur: 15,
                    child: Column(
                      children: [
                        Pinput(
                          controller: _otpController,
                          focusNode: _focusNode,
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          onCompleted: (_) => _handleVerifyOtp(),
                          autofocus: true,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20.0),
                        GradientButton(
                          text: widget.isRegistration ? 'Verify & Register' : 'Verify & Login',
                          onPressed: _handleVerifyOtp,
                          gradient: AppTheme.primaryGradient,
                          isLoading: _isLoading,
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 15.0),
                        if (_resendCountdown > 0)
                          Text(
                            'Resend OTP in $_resendCountdown seconds',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _isResending ? null : _handleResendOtp,
                            child: _isResending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.brandOrange,
                                    ),
                                  )
                                : Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: AppTheme.brandOrange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 32),
                  Center(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      blur: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.brandOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Flexible(
                            child: Text(
                              'OTP is valid for 5 minutes',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

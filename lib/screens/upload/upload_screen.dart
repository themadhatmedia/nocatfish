import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/upload_controller.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_text.dart';
import '../analysis/analysis_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final UploadController _uploadController = Get.put(UploadController());
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  // bool _consentAccepted = false;
  bool _consentPermission = false;
  bool _consentContent = false;
  bool _consentResult = false;
  bool _consentTerms = false;
  bool _consentDefame = false;

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
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildImagePreview(),
                      const SizedBox(height: 30),
                      _buildUploadButtons(),
                      const SizedBox(height: 30),
                      _buildConsentSection(),
                      const SizedBox(height: 30),
                      _buildAnalyzeButton(),
                      const SizedBox(height: 30),
                      _buildInfoSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Upload Photo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandOrange.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        GradientText(
          text: 'Verify Your Photo',
          gradient: AppTheme.primaryGradient,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        Text(
          'Upload a photo to check for AI manipulation and editing',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildImagePreview() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      blur: 15,
      child: Column(
        children: [
          if (_selectedImage != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.brandOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Photo selected',
                      style: TextStyle(
                        color: AppTheme.brandOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 50,
                    color: Colors.white,
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),
                const SizedBox(height: 20),
                const Text(
                  'No photo selected',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                // const SizedBox(height: 8),
                // const Text(
                //   'Choose a method below to upload',
                //   style: TextStyle(
                //     color: Colors.white38,
                //     fontSize: 13,
                //   ),
                // ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildUploadButtons() {
    return Row(
      children: [
        // Expanded(
        //   child: GradientButton(
        //     text: 'Take Photo',
        //     onPressed: _pickImageFromCamera,
        //     gradient: AppTheme.primaryGradient,
        //     icon: Icons.camera_alt,
        //     height: 60,
        //   ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
        // ),
        // const SizedBox(width: 12.0),
        Expanded(
          child: GradientButton(
            text: 'Gallery',
            onPressed: _pickImageFromGallery,
            // gradient: AppTheme.accentGradient,
            gradient: AppTheme.primaryGradient,
            icon: Icons.photo_library,
            height: 60,
          ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildConsentSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      blur: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Privacy & Consent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // CheckboxListTile(
          //   value: _consentAccepted,
          //   onChanged: (value) {
          //     setState(() {
          //       _consentAccepted = value ?? false;
          //     });
          //   },
          //   titleAlignment: ListTileTitleAlignment.top,
          //   activeColor: AppTheme.brandOrange,
          //   checkColor: Colors.white,
          //   title: const Text(
          //     'I confirm that I have the legal right to upload this image and consent to its analysis by this app for AI detection purposes. I understand that this image will not be stored or shared and is used solely for real-time analysis. The image and results will be stored until I manually delete them.',
          //     style: TextStyle(
          //       color: Colors.white70,
          //       fontSize: 13,
          //     ),
          //   ),
          //   controlAffinity: ListTileControlAffinity.leading,
          //   contentPadding: EdgeInsets.zero,
          // ),
          CheckboxListTile(
            value: _consentPermission,
            onChanged: (value) {
              setState(() {
                _consentPermission = value ?? false;
              });
            },
            titleAlignment: ListTileTitleAlignment.top,
            activeColor: AppTheme.brandOrange,
            checkColor: Colors.white,
            title: const Text(
              'You own or have permission to scan this photo.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _consentContent,
            onChanged: (value) {
              setState(() {
                _consentContent = value ?? false;
              });
            },
            titleAlignment: ListTileTitleAlignment.top,
            activeColor: AppTheme.brandOrange,
            checkColor: Colors.white,
            title: const Text(
              'No minors or explicit content will be uploaded.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _consentResult,
            onChanged: (value) {
              setState(() {
                _consentResult = value ?? false;
              });
            },
            titleAlignment: ListTileTitleAlignment.top,
            activeColor: AppTheme.brandOrange,
            checkColor: Colors.white,
            title: const Text(
              'Results are estimates, not identity verification.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _consentTerms,
            onChanged: (value) {
              setState(() {
                _consentTerms = value ?? false;
              });
            },
            titleAlignment: ListTileTitleAlignment.top,
            activeColor: AppTheme.brandOrange,
            checkColor: Colors.white,
            // title: Text(
            //   'You agree to the Terms of Use & Privacy Policy.',
            //   style: TextStyle(
            //     color: Colors.white70,
            //     fontSize: 13,
            //   ),
            // ),
            title: RichText(
              text: TextSpan(
                text: 'You agree to the ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Use',
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
                  TextSpan(text: ' & '),
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
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _consentDefame,
            onChanged: (value) {
              setState(() {
                _consentDefame = value ?? false;
              });
            },
            titleAlignment: ListTileTitleAlignment.top,
            activeColor: AppTheme.brandOrange,
            checkColor: Colors.white,
            title: const Text(
              'You will not use results to harass or defame others.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAnalyzeButton() {
    return Obx(() {
      final isUploading = _uploadController.isUploading;
      final canAnalyze = _selectedImage != null && (_consentPermission && _consentContent && _consentResult && _consentTerms && _consentDefame) && !isUploading;

      return GradientButton(
        text: isUploading ? 'Uploading...' : 'Analyze Photo',
        onPressed: canAnalyze ? _uploadAndAnalyze : () {},
        gradient: canAnalyze ? AppTheme.primaryGradient : AppTheme.accentGradient,
        icon: isUploading ? null : Icons.security,
        height: 64,
      ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
    });
  }

  Widget _buildInfoSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      blur: 10,
      child: Column(
        children: [
          // _buildInfoItem(
          //   Icons.delete_outline,
          //   'Auto-Delete',
          //   'Photos deleted within 24 hours',
          // ),
          // const Divider(color: Colors.white24, height: 32),
          _buildInfoItem(
            Icons.verified_user_outlined,
            'Secure Analysis',
            'End-to-end encrypted processing',
          ),
          const Divider(color: Colors.white24, height: 32),
          _buildInfoItem(
            Icons.insights_outlined,
            'AI Detection',
            'Advanced manipulation detection',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.brandOrange,
          size: 24,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Future<void> _pickImageFromCamera() async {
  //   final XFile? image = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     maxWidth: 1920,
  //     maxHeight: 1920,
  //     imageQuality: 85,
  //   );

  //   if (image != null) {
  //     setState(() {
  //       _selectedImage = File(image.path);
  //     });
  //   }
  // }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadAndAnalyze() async {
    if (_selectedImage == null || (!_consentPermission && !_consentContent && !_consentResult && !_consentTerms && !_consentDefame)) return;

    final result = await _uploadController.uploadImage(_selectedImage!);

    if (result.success && result.data != null) {
      Get.to(() => AnalysisScreen(
            consentLogId: result.data!.consentLogId,
          ));
    } else {
      Get.snackbar(
        'Upload Failed',
        result.errorMessage,
        backgroundColor: AppTheme.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }
}

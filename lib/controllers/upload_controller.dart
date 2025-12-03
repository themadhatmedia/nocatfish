import 'dart:io';

import 'package:get/get.dart';

import '../models/api_response.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class UploadController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rx<UploadLimitsData?> _limits = Rx<UploadLimitsData?>(null);
  final RxBool _isUploading = false.obs;
  final RxBool _isLoadingLimits = false.obs;
  final Rx<UploadResponseData?> _uploadResponse = Rx<UploadResponseData?>(null);
  final Rx<String?> _error = Rx<String?>(null);

  UploadLimitsData? get limits => _limits.value;
  bool get isUploading => _isUploading.value;
  bool get isLoadingLimits => _isLoadingLimits.value;
  UploadResponseData? get uploadResponse => _uploadResponse.value;
  String? get error => _error.value;

  int get remainingUploads => _limits.value?.remainingUploads ?? 0;
  int get maxDailyUploads => _limits.value?.maxDailyUploads ?? 50;

  @override
  void onInit() {
    super.onInit();
    loadLimits();
  }

  Future<void> loadLimits() async {
    final authController = Get.find<AuthController>();
    if (authController.token == null) return;

    _isLoadingLimits.value = true;
    _error.value = null;

    try {
      final response = await _apiService.getUploadLimits(authController.token!);

      if (response.success && response.data != null) {
        _limits.value = response.data;
      } else {
        _error.value = response.errorMessage;
      }
    } catch (e) {
      _error.value = 'Failed to load upload limits';
    }

    _isLoadingLimits.value = false;
  }

  Future<ApiResponse<UploadResponseData>> uploadImage(File imageFile) async {
    final authController = Get.find<AuthController>();
    if (authController.token == null) {
      return ApiResponse<UploadResponseData>(
        success: false,
        message: 'Not authenticated',
      );
    }

    _isUploading.value = true;
    _error.value = null;

    try {
      final response = await _apiService.uploadImage(
        token: authController.token!,
        imageFile: imageFile,
      );

      if (response.success && response.data != null) {
        _uploadResponse.value = response.data;
        await loadLimits();
      } else {
        _error.value = response.errorMessage;
      }

      _isUploading.value = false;
      return response;
    } catch (e) {
      _isUploading.value = false;
      _error.value = 'Failed to upload image';
      return ApiResponse<UploadResponseData>(
        success: false,
        message: 'Failed to upload image',
      );
    }
  }

  void clearError() {
    _error.value = null;
  }
}

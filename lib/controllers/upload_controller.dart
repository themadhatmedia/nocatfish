import 'dart:io';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/analytics_service.dart';
import '../models/api_response.dart';
import 'auth_controller.dart';

class UploadController extends GetxController {
  final ApiService _apiService = ApiService();
  late final AnalyticsService _analytics;

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
    _analytics = Get.find<AnalyticsService>();
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

        await _analytics.logScansRefreshed(
          remainingScans: response.data!.remainingUploads,
          maxScans: response.data!.maxDailyUploads,
        );
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

    final startTime = DateTime.now();
    final imageSize = await imageFile.length();

    await _analytics.logUploadStarted(
      imageSource: 'gallery',
      imageSize: imageSize,
    );

    try {
      final response = await _apiService.uploadImage(
        token: authController.token!,
        imageFile: imageFile,
      );

      if (response.success && response.data != null) {
        _uploadResponse.value = response.data;
        // await loadLimits();

        final duration = DateTime.now().difference(startTime).inSeconds;
        await _analytics.logUploadCompleted(
          imageSource: 'gallery',
          duration: duration,
          imageSize: imageSize,
        );
      } else {
        _error.value = response.errorMessage;
        await _analytics.logUploadFailed(
          errorMessage: response.errorMessage ?? 'Unknown error',
          imageSource: 'gallery',
        );
      }

      _isUploading.value = false;
      return response;
    } catch (e) {
      _isUploading.value = false;
      _error.value = 'Failed to upload image';
      await _analytics.logUploadFailed(
        errorMessage: e.toString(),
        imageSource: 'file',
      );
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

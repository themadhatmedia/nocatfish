import 'dart:async';

import 'package:get/get.dart';

import '../models/api_response.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class AnalysisController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxInt _consentLogId = 0.obs;
  final Rx<AnalysisStatusData?> _status = Rx<AnalysisStatusData?>(null);
  final RxBool _isPolling = false.obs;
  final Rx<String?> _error = Rx<String?>(null);
  final RxString _currentStep = 'Uploading image...'.obs;
  final RxDouble _progress = 0.0.obs;

  Timer? _pollTimer;
  int _pollCount = 0;

  AnalysisStatusData? get status => _status.value;
  Rx<AnalysisStatusData?> get statusRx => _status;
  bool get isPolling => _isPolling.value;
  String? get error => _error.value;
  String get currentStep => _currentStep.value;
  double get progress => _progress.value;

  final List<String> _steps = [
    'Uploading image...',
    'Processing image data...',
    'Running AI detection...',
    'Analyzing modifications...',
    'Calculating catfish score...',
    'Finalizing results...',
  ];

  void startAnalysis(int consentLogId) {
    _consentLogId.value = consentLogId;
    _pollCount = 0;
    _error.value = null;
    _startPolling();
  }

  void _startPolling() {
    _isPolling.value = true;
    _updateProgress();

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkStatus();
      _pollCount++;
      _updateProgress();
    });
  }

  void _updateProgress() {
    final stepIndex = (_pollCount ~/ 2).clamp(0, _steps.length - 1);
    _currentStep.value = _steps[stepIndex];
    _progress.value = (stepIndex + 1) / _steps.length;
  }

  Future<void> _checkStatus() async {
    final authController = Get.find<AuthController>();
    if (authController.token == null) return;

    try {
      final response = await _apiService.getAnalysisStatus(
        token: authController.token!,
        consentLogId: _consentLogId.value,
      );

      if (response.success && response.data != null) {
        _status.value = response.data;

        if (response.data!.isCompleted) {
          _currentStep.value = 'Analysis complete!';
          _progress.value = 1.0;
          stopPolling();
        }
      } else {
        _error.value = response.errorMessage;
        stopPolling();
      }
    } catch (e) {
      _error.value = 'Failed to check analysis status';
      stopPolling();
    }
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _isPolling.value = false;
  }

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }
}

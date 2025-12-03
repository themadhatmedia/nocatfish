import 'package:get/get.dart';

import '../models/api_response.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class ResultsController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rx<ScanResultData?> _currentResult = Rx<ScanResultData?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isDeleting = false.obs;
  final Rx<String?> _error = Rx<String?>(null);

  ScanResultData? get currentResult => _currentResult.value;
  bool get isLoading => _isLoading.value;
  bool get isDeleting => _isDeleting.value;
  String? get error => _error.value;

  Future<void> loadResult(int scanResultId) async {
    final authController = Get.find<AuthController>();
    if (authController.token == null) return;

    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await _apiService.getResults(
        token: authController.token!,
        scanResultId: scanResultId,
      );

      print('response.success: ${response.success}');
      print('response.data: ${response.data}');
      if (response.success && response.data != null) {
        _currentResult.value = response.data;
      } else {
        _error.value = response.errorMessage;
      }
    } catch (e) {
      _error.value = 'Failed to load results';
    }

    _isLoading.value = false;
  }

  Future<bool> deleteResult(int scanResultId) async {
    final authController = Get.find<AuthController>();
    if (authController.token == null) return false;

    _isDeleting.value = true;
    _error.value = null;

    try {
      final response = await _apiService.deleteResults(
        token: authController.token!,
        scanResultId: scanResultId,
      );

      _isDeleting.value = false;
      return response.success;
    } catch (e) {
      _isDeleting.value = false;
      _error.value = 'Failed to delete results';
      return false;
    }
  }

  void clearCurrentResult() {
    _currentResult.value = null;
  }

  void clearError() {
    _error.value = null;
  }
}

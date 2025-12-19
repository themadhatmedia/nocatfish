import 'package:get/get.dart';

import '../models/api_response.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = ApiService();

  Rx<DashboardData?> ddashboard = Rx<DashboardData?>(null);
  final RxBool _isLoading = false.obs;
  final Rx<String?> _error = Rx<String?>(null);

  DashboardData? get dashboard => ddashboard.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  DashboardStatistics? get statistics => ddashboard.value?.statistics;
  List<RecentResult>? get recentResults => ddashboard.value?.recentResults;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final authController = Get.find<AuthController>();
    if (authController.token == null) return;

    _isLoading.value = true;
    _error.value = null;

    print('isLoading: $isLoading');

    try {
      final response = await _apiService.getDashboard(authController.token!);
      print('response: $response');
      print('response.success: ${response.success}');
      print('response.data: ${response.data}');
      print('response.errors: ${response.errors}');
      print('response.message: ${response.message}');

      if (response.success && response.data != null) {
        ddashboard.value = response.data;
        print('ddashboard tokensBalance: ${ddashboard.value!.tokensBalance}');
      } else {
        _error.value = response.errorMessage;
      }
    } catch (e) {
      _error.value = 'Failed to load dashboard data';
    }

    _isLoading.value = false;
  }

  @override
  Future<void> refresh() async {
    await loadDashboard();
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/plan_model.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/stripe_service.dart';

class PlansController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final StripeService _stripeService = StripeService();
  late final AnalyticsService _analytics;

  final RxBool _isLoading = false.obs;
  final RxBool _isPurchasing = false.obs;
  final RxString _error = ''.obs;
  final RxString _errorplans = ''.obs;
  final RxList<PlanModel> _plans = <PlanModel>[].obs;
  final Rx<UserPlanData?> _currentUserPlan = Rx<UserPlanData?>(null);

  bool get isLoading => _isLoading.value;
  bool get isPurchasing => _isPurchasing.value;
  String get error => _error.value;
  String get errorplans => _errorplans.value;
  List<PlanModel> get plans => _plans;
  UserPlanData? get currentUserPlan => _currentUserPlan.value;
  PlanModel? get currentPlan => _currentUserPlan.value?.currentPlan;

  @override
  void onInit() {
    super.onInit();
    _analytics = Get.find<AnalyticsService>();
    loadPlans();
  }

  Future<void> loadPlans() async {
    _isLoading.value = true;
    _errorplans.value = '';

    try {
      final token = _storageService.getToken();
      if (token == null) {
        _errorplans.value = 'Not authenticated';
        _isLoading.value = false;
        return;
      }

      final response = await _apiService.getAllPlans(token);

      print('response controller: $response');
      print('response success: ${response.success}');
      print('response data: ${response.data}');
      print('response errorMessage: ${response.errorMessage}');

      if (response.success && response.data != null) {
        _plans.value = response.data!.plans;
        if (response.data!.currentPlan != null) {
          _currentUserPlan.value = UserPlanData(
            currentPlan: response.data!.currentPlan,
          );
        }
        _errorplans.value = '';
      } else {
        _errorplans.value = response.errorMessage;
      }
    } catch (e) {
      _errorplans.value = 'Failed to load plans: $e';
    }

    _isLoading.value = false;
  }

  Future<void> loadCurrentPlan() async {
    try {
      final token = _storageService.getToken();
      if (token == null) return;

      final response = await _apiService.getCurrentPlan(token);

      if (response.success && response.data != null) {
        _currentUserPlan.value = response.data;
      }
    } catch (e) {
      print('Failed to load current plan: $e');
    }
  }

  Future<bool> purchasePlanWithStripe(int planId, double amount) async {
    _isPurchasing.value = true;
    _error.value = '';

    final plan = _plans.firstWhereOrNull((p) => p.id == planId);
    final planName = plan?.name ?? 'Unknown Plan';

    await _analytics.logPurchaseStarted(
      packageId: planId.toString(),
      packageName: planName,
      price: amount,
      paymentMethod: 'stripe',
    );

    try {
      final paymentSuccess = await _stripeService.collectPayment(
        amount: amount,
        currency: 'usd',
        analytics: _analytics,
        planId: planId.toString(),
        planName: planName.toString(),
      );

      print('paymentSuccess: $paymentSuccess');

      if (!paymentSuccess) {
        debugPrint('payment here 3');
        _error.value = 'Payment was not completed';
        _isPurchasing.value = false;
        await _analytics.logPurchaseFailed(
          packageId: planId.toString(),
          errorMessage: 'Not authenticated',
          paymentMethod: 'stripe',
        );
        return false;
      }

      final token = _storageService.getToken();
      if (token == null) {
        _error.value = 'Not authenticated';
        _isPurchasing.value = false;
        return false;
      }

      final response = await _apiService.purchasePlan(
        token: token,
        planId: planId,
      );

      if (response.success) {
        // _currentUserPlan.value = response.data;
        _error.value = '';
        _isPurchasing.value = false;
        return true;
      } else {
        debugPrint('payment here 4');
        _error.value = response.errorMessage;
        _isPurchasing.value = false;
        return false;
      }
    } catch (e) {
      debugPrint('payment here 5');
      _error.value = 'Failed to purchase plan: $e';
      _isPurchasing.value = false;
      return false;
    }
  }

  Future<bool> purchasePlan(int planId) async {
    _isPurchasing.value = true;
    _error.value = '';

    try {
      final token = _storageService.getToken();
      if (token == null) {
        _error.value = 'Not authenticated';
        _isPurchasing.value = false;
        return false;
      }

      final response = await _apiService.purchasePlan(
        token: token,
        planId: planId,
      );

      if (response.success) {
        // _currentUserPlan.value = response.data;
        _error.value = '';
        _isPurchasing.value = false;
        return true;
      } else {
        _error.value = response.errorMessage;
        _isPurchasing.value = false;
        return false;
      }
    } catch (e) {
      _error.value = 'Failed to purchase plan: $e';
      _isPurchasing.value = false;
      return false;
    }
  }

  Future<bool> cancelPlan() async {
    _isPurchasing.value = true;
    _error.value = '';

    try {
      final token = _storageService.getToken();
      if (token == null) {
        _error.value = 'Not authenticated';
        _isPurchasing.value = false;
        return false;
      }

      final response = await _apiService.cancelPlan(token);

      if (response.success) {
        _currentUserPlan.value = null;
        _error.value = '';
        _isPurchasing.value = false;
        return true;
      } else {
        _error.value = response.errorMessage;
        _isPurchasing.value = false;
        return false;
      }
    } catch (e) {
      _error.value = 'Failed to cancel plan: $e';
      _isPurchasing.value = false;
      return false;
    }
  }

  void clearError() {
    _error.value = '';
  }

  bool isPlanActive(int planId) {
    return currentPlan?.id == planId && (_currentUserPlan.value?.isActive ?? false);
  }

  // bool canUpgrade() {
  // return _currentUserPlan.value?.canUpgrade ?? true;
  // }
}

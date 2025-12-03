import 'package:get/get.dart';

import '../models/api_response.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final StorageService _storage = StorageService();
  final ApiService _apiService = ApiService();

  final Rx<String?> _token = Rx<String?>(null);
  final Rx<Map<String, dynamic>?> _user = Rx<Map<String, dynamic>?>(null);
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isLoading = false.obs;
  final Rx<String?> _error = Rx<String?>(null);

  String? get token => _token.value;
  Map<String, dynamic>? get user => _user.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadAuthData();
  }

  Future<void> loadAuthData() async {
    final savedToken = _storage.getToken();
    final savedUser = _storage.getUser();

    print('\n=== LOADING AUTH DATA ===');
    print('Saved Token: ${savedToken?.substring(0, 20) ?? "null"}');
    print('Saved User: $savedUser');

    if (savedToken != null && savedUser != null) {
      _token.value = savedToken;
      _user.value = savedUser;
      _isAuthenticated.value = true;

      print('Auth State: Authenticated');
      print('=== END LOADING AUTH DATA ===\n');

      refreshUserData();
    } else {
      print('Auth State: Not Authenticated');
      print('=== END LOADING AUTH DATA ===\n');
    }
  }

  Future<bool> checkAuth() async {
    await loadAuthData();
    return _isAuthenticated.value;
  }

  Future<void> refreshUserData() async {
    if (_token.value == null) return;

    try {
      final response = await _apiService.getUser(_token.value!);
      if (response.success && response.data != null) {
        final userData = response.data!.toJson();
        _user.value = userData;
        await _storage.saveUser(userData);
      }
    } catch (e) {
      print('catch block');
    }
  }

  Future<ApiResponse<AuthData>> login(String email, String password) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        final authData = response.data!;
        _token.value = authData.token;
        _user.value = authData.user.toJson();
        _isAuthenticated.value = true;

        await _storage.saveToken(authData.token);
        await _storage.saveUser(authData.user.toJson());
      } else {
        _error.value = response.errorMessage;
      }

      _isLoading.value = false;
      return response;
    } catch (e) {
      _isLoading.value = false;
      _error.value = 'An unexpected error occurred';
      return ApiResponse<AuthData>(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  Future<ApiResponse<AuthData>> register(
    String name,
    String email,
    String password,
  ) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: password,
      );

      if (response.success && response.data != null) {
        final authData = response.data!;
        _token.value = authData.token;
        _user.value = authData.user.toJson();
        _isAuthenticated.value = true;

        await _storage.saveToken(authData.token);
        await _storage.saveUser(authData.user.toJson());
      } else {
        _error.value = response.errorMessage;
      }

      _isLoading.value = false;
      return response;
    } catch (e) {
      _isLoading.value = false;
      _error.value = 'An unexpected error occurred';
      return ApiResponse<AuthData>(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  Future<void> updateUserData(Map<String, dynamic> userData) async {
    _user.value = userData;
    await _storage.saveUser(userData);
  }

  Future<void> logout() async {
    if (_token.value != null) {
      await _apiService.logout(_token.value!);
    }

    _token.value = null;
    _user.value = null;
    _isAuthenticated.value = false;

    await _storage.clearAuthData();
  }
}

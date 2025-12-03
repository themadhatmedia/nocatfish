import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/plan_model.dart';
import '../screens/welcome_screen.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<ApiResponse<AuthData>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.register}');
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'privacy_policy_accepted': true,
        'terms_accepted': true,
      };

      print('\n=== API REQUEST: REGISTER ===');
      print('URL: $url');
      print('Method: POST');
      print('Body: ${jsonEncode(body)}');

      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<AuthData>(
          success: true,
          message: jsonData['message'],
          data: AuthData.fromJson(jsonData['data']),
        );
      } else {
        return ApiResponse<AuthData>(
          success: false,
          message: jsonData['message'],
          errors: jsonData['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<AuthData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future<ApiResponse<AuthData>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.login}');
      final body = {
        'email': email,
        'password': password,
      };

      print('\n=== API REQUEST: LOGIN ===');
      print('URL: $url');
      print('Method: POST');
      print('Body: ${jsonEncode(body)}');

      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<AuthData>(
          success: true,
          message: jsonData['message'],
          data: AuthData.fromJson(jsonData['data']),
        );
      } else {
        return ApiResponse<AuthData>(
          success: false,
          message: jsonData['message'],
          errors: jsonData['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<AuthData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future logout(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.logout}');

      print('\n=== API REQUEST: LOGOUT ===');
      print('URL: $url');
      print('Method: POST');
      print('Token: $token');

      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 401) {
        StorageService().clearAuthData();
        Get.offAll(() => const WelcomeScreen());
        return;
      }

      return ApiResponse<void>(
        success: response.statusCode == 200,
        message: jsonData['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future getUser(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.user}');

      print('\n=== API REQUEST: GET USER ===');
      print('URL: $url');
      print('Method: GET');
      print('Token: $token');

      final response = await http
          .get(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<UserData>(
          success: true,
          data: UserData.fromJson(jsonData['data']),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<UserData>(
          success: false,
          message: jsonData['message'],
        );
      }
    } catch (e) {
      return ApiResponse<UserData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future updateUser({
    required String token,
    String? name,
    String? email,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.updateUser}');

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (currentPassword != null) body['current_password'] = currentPassword;
      if (password != null) body['password'] = password;
      if (passwordConfirmation != null) {
        body['password_confirmation'] = passwordConfirmation;
      }

      print('\n=== API REQUEST: UPDATE USER ===');
      print('URL: $url');
      print('Method: PATCH');
      print('Token: $token');
      print('Body: ${jsonEncode(body)}');

      final response = await http
          .patch(
            url,
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<UserData>(
          success: true,
          message: jsonData['message'],
          data: UserData.fromJson(jsonData['data']),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<UserData>(
          success: false,
          message: jsonData['message'],
          errors: jsonData['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<UserData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future getUploadLimits(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.uploadLimits}');

      print('\n=== API REQUEST: GET UPLOAD LIMITS ===');
      print('URL: $url');
      print('Method: GET');
      print('Token: $token');

      final response = await http
          .get(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<UploadLimitsData>(
          success: true,
          data: UploadLimitsData.fromJson(jsonData['data']),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<UploadLimitsData>(
          success: false,
          message: jsonData['message'],
        );
      }
    } catch (e) {
      return ApiResponse<UploadLimitsData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future uploadImage({
    required String token,
    required File imageFile,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.upload}');

      print('\n=== API REQUEST: UPLOAD IMAGE ===');
      print('URL: $url');
      print('Method: POST (Multipart)');
      print('Token: $token');
      print('Image Path: ${imageFile.path}');
      print('Image Size: ${await imageFile.length()} bytes');
      print('Fields: {consent_accepted: true}');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(ApiConfig.getMultipartHeaders(token: token));

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      request.fields['consent_accepted'] = 'true';

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );

      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<UploadResponseData>(
          success: true,
          message: jsonData['message'],
          data: UploadResponseData.fromJson(jsonData['data']),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<UploadResponseData>(
          success: false,
          message: jsonData['message'],
          errors: jsonData['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<UploadResponseData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future getAnalysisStatus({required String token, required int consentLogId}) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.apiBaseUrl}${ApiEndpoints.analysisStatus(consentLogId)}',
      );

      print('\n=== API REQUEST: GET ANALYSIS STATUS ===');
      print('URL: $url');
      print('Method: GET');
      print('Token: $token');
      print('Consent Log ID: $consentLogId');

      final response = await http
          .get(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<AnalysisStatusData>(
          success: true,
          data: AnalysisStatusData.fromJson(jsonData['data']),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<AnalysisStatusData>(
          success: false,
          message: jsonData['message'],
        );
      }
    } catch (e) {
      return ApiResponse<AnalysisStatusData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future getResults({
    required String token,
    required int scanResultId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.apiBaseUrl}${ApiEndpoints.results(scanResultId)}',
      );

      print('\n=== API REQUEST: GET RESULTS ===');
      print('URL: $url');
      print('Method: GET');
      print('Token: $token');
      print('Scan Result ID: $scanResultId');

      final response = await http
          .get(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<ScanResultData>(
          success: true,
          message: jsonData['message'],
          data: ScanResultData.fromJson(jsonData['data']),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<ScanResultData>(
          success: false,
          message: jsonData['message'],
        );
      }
    } catch (e) {
      return ApiResponse<ScanResultData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future<ApiResponse<void>> deleteResults({
    required String token,
    required int scanResultId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.apiBaseUrl}${ApiEndpoints.deleteResults(scanResultId)}',
      );

      print('\n=== API REQUEST: DELETE RESULTS ===');
      print('URL: $url');
      print('Method: DELETE');
      print('Token: $token');
      print('Scan Result ID: $scanResultId');

      final response = await http
          .delete(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      return ApiResponse<void>(
        success: response.statusCode == 200,
        message: jsonData['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future getDashboard(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.dashboard}');

      final response = await http
          .get(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('\n=== API REQUEST: GET DASHBOARD ===');
      print('URL: $url');
      print('Method: GET');
      print('Token: $token');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        try {
          final data = DashboardData.fromJson(jsonData['data']);
          print('Parse Success: Dashboard data parsed correctly');
          print('=== END REQUEST ===\n');
          return ApiResponse<DashboardData>(
            success: true,
            data: data,
          );
        } catch (parseError) {
          print('Parse Error: $parseError');
          print('JSON Data: ${jsonData['data']}');
          print('=== END REQUEST ===\n');
          return ApiResponse<DashboardData>(
            success: false,
            message: 'Failed to parse dashboard data: $parseError',
          );
        }
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<DashboardData>(
          success: false,
          message: jsonData['message'],
        );
      }
    } catch (e) {
      print('Request Error: $e');
      print('=== END REQUEST ===\n');
      return ApiResponse<DashboardData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future getApiStatus() async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.status}');

      print('\n=== API REQUEST: GET STATUS ===');
      print('URL: $url');
      print('Method: GET');

      final response = await http.get(url).timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: jsonData,
        );
      } else if (response.statusCode == 401) {
        // logout(token);
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'API is offline',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future getAllPlans(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.plans}');

      print('\n=== API REQUEST: GET ALL PLANS ===');
      print('URL: $url');
      print('Method: GET');
      print('Token: ${token.substring(0, 20)}...');

      final response = await http
          .get(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);
      print('jsonData: $jsonData');
      print('fromJson: ${PlansListData.fromJson(jsonData)}');

      if (response.statusCode == 200) {
        return ApiResponse<PlansListData>(
          success: true,
          message: jsonData['message'] ?? 'success',
          data: PlansListData.fromJson(jsonData),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<PlansListData>(
          success: false,
          message: jsonData['message'],
        );
      }
    } catch (e) {
      return ApiResponse<PlansListData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future getCurrentPlan(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.currentPlan}');

      print('\n=== API REQUEST: GET CURRENT PLAN ===');
      print('URL: $url');
      print('Method: GET');
      print('Token: ${token.substring(0, 20)}...');

      final response = await http
          .get(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<UserPlanData>(
          success: true,
          message: jsonData['message'],
          data: UserPlanData.fromJson(jsonData['data']),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<UserPlanData>(
          success: false,
          message: jsonData['message'],
        );
      }
    } catch (e) {
      return ApiResponse<UserPlanData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future purchasePlan({
    required String token,
    required int planId,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.purchasePlan}');
      final body = {'plan_id': planId};

      print('\n=== API REQUEST: PURCHASE PLAN ===');
      print('URL: $url');
      print('Method: POST');
      print('Token: ${token.substring(0, 20)}...');
      print('Body: ${jsonEncode(body)}');

      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<UserPlanData>(
          success: true,
          message: jsonData['message'],
          // data: UserPlanData.fromJson(jsonData['data']),
        );
      } else if (response.statusCode == 401) {
        logout(token);
      } else {
        return ApiResponse<UserPlanData>(
          success: false,
          message: jsonData['message'],
          errors: jsonData['errors'],
        );
      }
    } catch (e) {
      return ApiResponse<UserPlanData>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  Future<ApiResponse<void>> cancelPlan(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}${ApiEndpoints.cancelPlan}');

      print('\n=== API REQUEST: CANCEL PLAN ===');
      print('URL: $url');
      print('Method: DELETE');
      print('Token: ${token.substring(0, 20)}...');

      final response = await http
          .delete(
            url,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END REQUEST ===\n');

      final jsonData = jsonDecode(response.body);

      return ApiResponse<void>(
        success: response.statusCode == 200,
        message: jsonData['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: _handleError(e),
      );
    }
  }

  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is http.ClientException) {
      return 'Connection failed. Please try again.';
    } else if (error is FormatException) {
      return 'Invalid response from server.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

class ApiConfig {
  static const String baseUrl = 'https://nocatfish.app/api/v1';

  static const String localBaseUrl = 'http://localhost:8000/api/v1';

  static const bool useLocalApi = false;

  static String get apiBaseUrl => useLocalApi ? localBaseUrl : baseUrl;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int maxFileSizeMB = 10;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Map<String, String> getMultipartHeaders({String? token}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}

class ApiEndpoints {
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  static const String user = '/user';
  static const String updateUser = '/user';

  static const String uploadLimits = '/upload/limits';
  static const String upload = '/upload';

  static String analysisStatus(int consentLogId) => '/analysis/$consentLogId/status';

  static String results(int scanResultId) => '/results/$scanResultId';
  static String deleteResults(int scanResultId) => '/results/$scanResultId';

  static const String dashboard = '/dashboard';
  static const String history = '/history';

  static const String status = '/status';

  static const String plans = '/plans';
  static const String currentPlan = '/plans/current';
  static const String purchasePlan = '/plans/purchase';
  static const String cancelPlan = '/plans/cancel';
}

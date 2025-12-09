class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && dataParser != null ? dataParser(json['data']) : json['data'] as T?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  bool get hasError => !success || errors != null;

  String get errorMessage {
    if (message != null) return message!;
    if (errors != null) {
      final errorList = errors!.values.expand((e) => e as List).toList();
      return errorList.join(', ');
    }
    return 'An unexpected error occurred';
  }
}

class UserData {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final bool? twoFactorEnabled;
  // final String? lastLoginAt;
  // final String createdAt;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.twoFactorEnabled,
    // this.lastLoginAt,
    // required this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 1,
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'] ?? '',
      twoFactorEnabled: json['two_factor_enabled'] ?? true,
      // lastLoginAt: json['last_login_at'],
      // createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'two_factor_enabled': twoFactorEnabled,
      // 'last_login_at': lastLoginAt,
      // 'created_at': createdAt,
    };
  }
}

class AuthData {
  final UserData user;
  final String token;

  AuthData({
    required this.user,
    required this.token,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    print('AuthData.fromJson.json: $json');
    return AuthData(
      user: UserData.fromJson(json['user']),
      token: json['token'],
    );
  }
}

class UploadLimitsData {
  final int remainingUploads;
  final int maxDailyUploads;
  final int maxFileSizeMb;
  final List<String> allowedExtensions;
  final int autoDeleteMinutes;

  UploadLimitsData({
    required this.remainingUploads,
    required this.maxDailyUploads,
    required this.maxFileSizeMb,
    required this.allowedExtensions,
    required this.autoDeleteMinutes,
  });

  factory UploadLimitsData.fromJson(Map<String, dynamic> json) {
    return UploadLimitsData(
      remainingUploads: json['remaining_uploads'],
      maxDailyUploads: json['max_daily_uploads'],
      maxFileSizeMb: json['max_file_size_mb'],
      allowedExtensions: List<String>.from(json['allowed_extensions']),
      autoDeleteMinutes: json['auto_delete_minutes'],
    );
  }
}

class UploadResponseData {
  final int consentLogId;
  final String expiresAt;
  final int timeRemainingSeconds;
  final String analysisUrl;

  UploadResponseData({
    required this.consentLogId,
    required this.expiresAt,
    required this.timeRemainingSeconds,
    required this.analysisUrl,
  });

  factory UploadResponseData.fromJson(Map<String, dynamic> json) {
    return UploadResponseData(
      consentLogId: json['consent_log_id'],
      expiresAt: json['expires_at'] ?? '',
      timeRemainingSeconds: json['time_remaining_seconds'] ?? 1000,
      analysisUrl: json['analysis_url'],
    );
  }
}

class AnalysisStatusData {
  final String status;
  final int? timeRemainingSeconds;
  final int? scanResultId;
  final String? resultsUrl;

  AnalysisStatusData({
    required this.status,
    this.timeRemainingSeconds,
    this.scanResultId,
    this.resultsUrl,
  });

  factory AnalysisStatusData.fromJson(Map<String, dynamic> json) {
    return AnalysisStatusData(
      status: json['status'],
      timeRemainingSeconds: json['time_remaining_seconds'],
      scanResultId: json['scan_result_id'],
      resultsUrl: json['results_url'],
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isProcessing => status == 'processing';
}

class DetectionItem {
  final String type;
  final String label;
  final String description;
  final int confidence;
  final int scoreContribution;

  DetectionItem({
    required this.type,
    required this.label,
    required this.description,
    required this.confidence,
    required this.scoreContribution,
  });

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      type: json['type'],
      label: json['label'],
      description: json['description'],
      confidence: json['confidence'],
      scoreContribution: json['score_contribution'],
    );
  }
}

class DetectionCategory {
  final String categoryName;
  final int detectionCount;
  final List<DetectionItem> detections;

  DetectionCategory({
    required this.categoryName,
    required this.detectionCount,
    required this.detections,
  });

  factory DetectionCategory.fromJson(Map<String, dynamic> json) {
    return DetectionCategory(
      categoryName: json['category_name'],
      detectionCount: json['detection_count'],
      detections: (json['detections'] as List).map((e) => DetectionItem.fromJson(e)).toList(),
    );
  }
}

class CatfishLevel {
  final String label;
  final String description;
  final String color;

  CatfishLevel({
    required this.label,
    required this.description,
    required this.color,
  });

  factory CatfishLevel.fromJson(Map<String, dynamic> json) {
    return CatfishLevel(
      label: json['label'],
      description: json['description'],
      color: json['color'],
    );
  }
}

class ScanResultData {
  final int scanResultId;
  final int catfishScore;
  final CatfishLevel catfishLevel;
  final String analysisCompletedAt;
  final String expiresAt;
  final int timeRemainingSeconds;
  final int totalDetections;
  final List<DetectionCategory> detectionsByCategory;
  final String privacyNotice;
  final String imageURL;

  ScanResultData({
    required this.scanResultId,
    required this.catfishScore,
    required this.catfishLevel,
    required this.analysisCompletedAt,
    required this.expiresAt,
    required this.timeRemainingSeconds,
    required this.totalDetections,
    required this.detectionsByCategory,
    required this.privacyNotice,
    this.imageURL = '',
  });

  factory ScanResultData.fromJson(Map<String, dynamic> json) {
    final detections = json['detections'] as Map<String, dynamic>;
    return ScanResultData(
      scanResultId: json['scan_result_id'],
      catfishScore: json['catfish_score'],
      catfishLevel: CatfishLevel.fromJson(json['catfish_level']),
      analysisCompletedAt: json['analysis_completed_at'],
      expiresAt: json['expires_at'] ?? '',
      timeRemainingSeconds: json['time_remaining_seconds'] ?? 1500,
      totalDetections: detections['total_count'],
      detectionsByCategory: (detections['by_category'] as List).map((e) => DetectionCategory.fromJson(e)).toList(),
      privacyNotice: json['privacy_notice'],
      imageURL: json['image_url'] ?? '',
    );
  }
}

class DashboardStatistics {
  final int totalUploadsToday;
  final int totalUploadsThisWeek;
  final int activeResults;
  final int remainingUploads;
  final int maxDailyUploads;

  DashboardStatistics({
    required this.totalUploadsToday,
    required this.totalUploadsThisWeek,
    required this.activeResults,
    required this.remainingUploads,
    required this.maxDailyUploads,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      totalUploadsToday: json['total_uploads_today'],
      totalUploadsThisWeek: json['total_uploads_this_week'],
      activeResults: json['active_results'],
      remainingUploads: json['remaining_uploads'],
      maxDailyUploads: int.parse(json['max_daily_uploads'].toString()),
    );
  }
}

class RecentResult {
  final int id;
  final int catfishScore;
  final String catfishLevel;
  final String analysisCompletedAt;
  final String expiresAt;
  final int timeRemainingSeconds;

  RecentResult({
    required this.id,
    required this.catfishScore,
    required this.catfishLevel,
    required this.analysisCompletedAt,
    required this.expiresAt,
    required this.timeRemainingSeconds,
  });

  factory RecentResult.fromJson(Map<String, dynamic> json) {
    return RecentResult(
      id: json['id'],
      catfishScore: json['catfish_score'],
      catfishLevel: json['catfish_level'],
      analysisCompletedAt: json['analysis_completed_at'],
      expiresAt: json['expires_at'] ?? '',
      timeRemainingSeconds: json['time_remaining_seconds'] ?? 1500,
    );
  }
}

class DashboardData {
  final UserData user;
  final DashboardStatistics statistics;
  final List<RecentResult> recentResults;
  final String privacyNotice;
  final String tokensBalance;

  DashboardData({
    required this.user,
    required this.statistics,
    required this.recentResults,
    required this.privacyNotice,
    required this.tokensBalance,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: UserData.fromJson(json['user']),
      statistics: DashboardStatistics.fromJson(json['statistics']),
      recentResults: (json['recent_results'] as List).map((e) => RecentResult.fromJson(e)).toList(),
      privacyNotice: json['privacy_notice'],
      tokensBalance: json['tokens_remaining'] != null ? json['tokens_remaining'].toString() : '0',
    );
  }
}

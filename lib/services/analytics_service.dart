import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

import '../config/analytics_events.dart';

class AnalyticsService extends GetxService {
  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;

  FirebaseAnalyticsObserver get observer => _observer;

  Future<AnalyticsService> init() async {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    return this;
  }

  // Set user properties
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperties({
    String? email,
    String? name,
    String? phone,
  }) async {
    if (email != null) {
      await _analytics.setUserProperty(name: 'user_email', value: email);
    }
    if (name != null) {
      await _analytics.setUserProperty(name: 'user_name', value: name);
    }
    if (phone != null) {
      await _analytics.setUserProperty(name: 'user_phone', value: phone);
    }
  }

  Future<void> clearUser() async {
    await _analytics.setUserId(id: null);
  }

  // Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    print('logEvent name: $name');
    print('logEvent parameters: $parameters');
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // Authentication Events
  Future<void> logAppOpened() async {
    await logEvent(name: AnalyticsEvents.appOpened);
  }

  Future<void> logSignUpStarted({String? method}) async {
    await logEvent(
      name: AnalyticsEvents.signUpStarted,
      parameters: {
        if (method != null) AnalyticsParameters.method: method,
      },
    );
  }

  Future<void> logSignUpCompleted({
    required String userId,
    String? method,
  }) async {
    await logEvent(
      name: AnalyticsEvents.signUpCompleted,
      parameters: {
        AnalyticsParameters.userId: userId,
        if (method != null) AnalyticsParameters.method: method,
      },
    );
  }

  Future<void> logSignUpFailed({
    required String errorMessage,
    String? method,
  }) async {
    await logEvent(
      name: AnalyticsEvents.signUpFailed,
      parameters: {
        AnalyticsParameters.errorMessage: errorMessage,
        if (method != null) AnalyticsParameters.method: method,
      },
    );
  }

  Future<void> logLoginStarted({String? method}) async {
    await logEvent(
      name: AnalyticsEvents.loginStarted,
      parameters: {
        if (method != null) AnalyticsParameters.method: method,
      },
    );
  }

  Future<void> logLoginCompleted({
    required String userId,
    String? method,
  }) async {
    await logEvent(
      name: AnalyticsEvents.loginCompleted,
      parameters: {
        AnalyticsParameters.userId: userId,
        if (method != null) AnalyticsParameters.method: method,
      },
    );
  }

  Future<void> logLoginFailed({
    required String errorMessage,
    String? method,
  }) async {
    await logEvent(
      name: AnalyticsEvents.loginFailed,
      parameters: {
        AnalyticsParameters.errorMessage: errorMessage,
        if (method != null) AnalyticsParameters.method: method,
      },
    );
  }

  Future<void> logLogout() async {
    await logEvent(name: AnalyticsEvents.logoutCompleted);
  }

  Future<void> logOtpRequested({required String phone}) async {
    await logEvent(
      name: AnalyticsEvents.otpRequested,
      parameters: {
        AnalyticsParameters.userPhone: phone,
      },
    );
  }

  Future<void> logOtpVerified({required String phone}) async {
    await logEvent(
      name: AnalyticsEvents.otpVerified,
      parameters: {
        AnalyticsParameters.userPhone: phone,
      },
    );
  }

  Future<void> logOtpFailed({
    required String phone,
    required String errorMessage,
  }) async {
    await logEvent(
      name: AnalyticsEvents.otpFailed,
      parameters: {
        AnalyticsParameters.userPhone: phone,
        AnalyticsParameters.errorMessage: errorMessage,
      },
    );
  }

  // Upload Events
  Future<void> logUploadScreenViewed() async {
    await logEvent(name: AnalyticsEvents.uploadScreenViewed);
  }

  Future<void> logPhotoSelected({required String source}) async {
    await logEvent(
      name: source == 'camera' ? AnalyticsEvents.photoFromCamera : AnalyticsEvents.photoFromGallery,
      parameters: {
        AnalyticsParameters.imageSource: source,
      },
    );
  }

  Future<void> logConsentAccepted() async {
    await logEvent(
      name: AnalyticsEvents.consentAccepted,
      parameters: {
        AnalyticsParameters.consentGiven: true,
      },
    );
  }

  Future<void> logUploadStarted({
    required String imageSource,
    int? imageSize,
  }) async {
    await logEvent(
      name: AnalyticsEvents.uploadStarted,
      parameters: {
        AnalyticsParameters.imageSource: imageSource,
        if (imageSize != null) AnalyticsParameters.imageSize: imageSize,
      },
    );
  }

  Future<void> logUploadCompleted({
    required String imageSource,
    required int duration,
    int? imageSize,
  }) async {
    await logEvent(
      name: AnalyticsEvents.uploadCompleted,
      parameters: {
        AnalyticsParameters.imageSource: imageSource,
        AnalyticsParameters.uploadDuration: duration,
        if (imageSize != null) AnalyticsParameters.imageSize: imageSize,
      },
    );
  }

  Future<void> logUploadFailed({
    required String errorMessage,
    String? imageSource,
  }) async {
    await logEvent(
      name: AnalyticsEvents.uploadFailed,
      parameters: {
        AnalyticsParameters.errorMessage: errorMessage,
        if (imageSource != null) AnalyticsParameters.imageSource: imageSource,
      },
    );
  }

  // Analysis Events
  Future<void> logAnalysisStarted({required String analysisId}) async {
    await logEvent(
      name: AnalyticsEvents.analysisStarted,
      parameters: {
        AnalyticsParameters.analysisId: analysisId,
      },
    );
  }

  Future<void> logAnalysisCompleted({
    required String analysisId,
    required int score,
    required int duration,
    bool? aiDetected,
    bool? manipulationDetected,
  }) async {
    await logEvent(
      name: AnalyticsEvents.analysisCompleted,
      parameters: {
        AnalyticsParameters.analysisId: analysisId,
        AnalyticsParameters.analysisScore: score,
        AnalyticsParameters.analysisDuration: duration,
        if (aiDetected != null) AnalyticsParameters.aiDetected: aiDetected,
        if (manipulationDetected != null) AnalyticsParameters.manipulationDetected: manipulationDetected,
      },
    );
  }

  Future<void> logAnalysisFailed({
    required String analysisId,
    required String errorMessage,
  }) async {
    await logEvent(
      name: AnalyticsEvents.analysisFailed,
      parameters: {
        AnalyticsParameters.analysisId: analysisId,
        AnalyticsParameters.errorMessage: errorMessage,
      },
    );
  }

  Future<void> logAnalysisResultViewed({
    required String analysisId,
    required int score,
  }) async {
    await logEvent(
      name: AnalyticsEvents.analysisResultViewed,
      parameters: {
        AnalyticsParameters.analysisId: analysisId,
        AnalyticsParameters.analysisScore: score,
      },
    );
  }

  // Results Events
  Future<void> logResultsScreenViewed() async {
    await logEvent(name: AnalyticsEvents.resultsScreenViewed);
  }

  Future<void> logResultDetailViewed({
    required String resultId,
    required int score,
  }) async {
    await logEvent(
      name: AnalyticsEvents.resultDetailViewed,
      parameters: {
        AnalyticsParameters.analysisId: resultId,
        AnalyticsParameters.analysisScore: score,
      },
    );
  }

  // Scan Management Events
  Future<void> logLowScansWarning({required int remainingScans}) async {
    await logEvent(
      name: AnalyticsEvents.lowScansWarningShown,
      parameters: {
        AnalyticsParameters.remainingScans: remainingScans,
      },
    );
  }

  Future<void> logNoScansError() async {
    await logEvent(
      name: AnalyticsEvents.noScansError,
      parameters: {
        AnalyticsParameters.remainingScans: 0,
      },
    );
  }

  Future<void> logScansRefreshed({
    required int remainingScans,
    required int maxScans,
  }) async {
    await logEvent(
      name: AnalyticsEvents.scansRefreshed,
      parameters: {
        AnalyticsParameters.remainingScans: remainingScans,
        AnalyticsParameters.maxScans: maxScans,
      },
    );
  }

  // Package/Purchase Events
  Future<void> logPackagesScreenViewed() async {
    await logEvent(name: AnalyticsEvents.packagesScreenViewed);
  }

  Future<void> logPackageSelected({
    required String packageId,
    required String packageName,
    required double price,
    required int scans,
  }) async {
    await logEvent(
      name: AnalyticsEvents.packageSelected,
      parameters: {
        AnalyticsParameters.packageId: packageId,
        AnalyticsParameters.packageName: packageName,
        AnalyticsParameters.packagePrice: price,
        AnalyticsParameters.packageScans: scans,
      },
    );
  }

  Future<void> logPurchaseStarted({
    required String packageId,
    required String packageName,
    required double price,
    required String paymentMethod,
  }) async {
    await logEvent(
      name: AnalyticsEvents.purchaseStarted,
      parameters: {
        AnalyticsParameters.packageId: packageId,
        AnalyticsParameters.packageName: packageName,
        AnalyticsParameters.packagePrice: price,
        AnalyticsParameters.paymentMethod: paymentMethod,
      },
    );
  }

  Future<void> logPurchaseCompleted({
    required String packageId,
    required String packageName,
    required double price,
    required String paymentMethod,
    String? transactionId,
  }) async {
    await logEvent(
      name: AnalyticsEvents.purchaseCompleted,
      parameters: {
        AnalyticsParameters.packageId: packageId,
        AnalyticsParameters.packageName: packageName,
        AnalyticsParameters.packagePrice: price,
        AnalyticsParameters.paymentMethod: paymentMethod,
        if (transactionId != null) AnalyticsParameters.transactionId: transactionId,
      },
    );
  }

  Future<void> logPurchaseFailed({
    required String packageId,
    required String errorMessage,
    String? paymentMethod,
  }) async {
    await logEvent(
      name: AnalyticsEvents.purchaseFailed,
      parameters: {
        AnalyticsParameters.packageId: packageId,
        AnalyticsParameters.errorMessage: errorMessage,
        if (paymentMethod != null) AnalyticsParameters.paymentMethod: paymentMethod,
      },
    );
  }

  Future<void> logPurchaseCancelled({
    required String packageId,
    String? paymentMethod,
  }) async {
    await logEvent(
      name: AnalyticsEvents.purchaseCancelled,
      parameters: {
        AnalyticsParameters.packageId: packageId,
        if (paymentMethod != null) AnalyticsParameters.paymentMethod: paymentMethod,
      },
    );
  }

  // Profile Events
  Future<void> logProfileScreenViewed() async {
    await logEvent(name: AnalyticsEvents.profileScreenViewed);
  }

  Future<void> logProfileEditStarted() async {
    await logEvent(name: AnalyticsEvents.profileEditStarted);
  }

  Future<void> logProfileUpdated() async {
    await logEvent(name: AnalyticsEvents.profileUpdated);
  }

  Future<void> logProfileUpdateFailed({required String errorMessage}) async {
    await logEvent(
      name: AnalyticsEvents.profileUpdateFailed,
      parameters: {
        AnalyticsParameters.errorMessage: errorMessage,
      },
    );
  }

  // Dashboard Events
  Future<void> logDashboardViewed() async {
    await logEvent(name: AnalyticsEvents.dashboardViewed);
  }

  // Screen Tracking
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // Button Tracking
  Future<void> logButtonClick({
    required String buttonName,
    String? screenName,
  }) async {
    await logEvent(
      name: AnalyticsEvents.buttonClicked,
      parameters: {
        AnalyticsParameters.buttonName: buttonName,
        if (screenName != null) AnalyticsParameters.screenName: screenName,
      },
    );
  }

  // Error Tracking
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? errorCode,
  }) async {
    await logEvent(
      name: AnalyticsEvents.errorOccurred,
      parameters: {
        AnalyticsParameters.errorType: errorType,
        AnalyticsParameters.errorMessage: errorMessage,
        if (errorCode != null) AnalyticsParameters.errorCode: errorCode,
      },
    );
  }

  Future<void> logApiError({
    required String endpoint,
    required String errorMessage,
    int? statusCode,
  }) async {
    await logEvent(
      name: AnalyticsEvents.apiError,
      parameters: {
        AnalyticsParameters.errorType: 'api_error',
        AnalyticsParameters.errorMessage: errorMessage,
        'endpoint': endpoint,
        if (statusCode != null) AnalyticsParameters.errorCode: statusCode.toString(),
      },
    );
  }
}

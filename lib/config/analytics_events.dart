class AnalyticsEvents {
  // Authentication Events
  static const String appOpened = 'app_opened';
  static const String signUpStarted = 'sign_up_started';
  static const String signUpCompleted = 'sign_up_completed';
  static const String signUpFailed = 'sign_up_failed';
  static const String loginStarted = 'login_started';
  static const String loginCompleted = 'login_completed';
  static const String loginFailed = 'login_failed';
  static const String logoutCompleted = 'logout_completed';
  static const String otpRequested = 'otp_requested';
  static const String otpVerified = 'otp_verified';
  static const String otpFailed = 'otp_failed';

  // Upload Events
  static const String uploadScreenViewed = 'upload_screen_viewed';
  static const String photoSelected = 'photo_selected';
  static const String photoFromCamera = 'photo_from_camera';
  static const String photoFromGallery = 'photo_from_gallery';
  static const String consentAccepted = 'consent_accepted';
  static const String uploadStarted = 'upload_started';
  static const String uploadCompleted = 'upload_completed';
  static const String uploadFailed = 'upload_failed';

  // Analysis Events
  static const String analysisStarted = 'analysis_started';
  static const String analysisCompleted = 'analysis_completed';
  static const String analysisFailed = 'analysis_failed';
  static const String analysisResultViewed = 'analysis_result_viewed';

  // Results Events
  static const String resultsScreenViewed = 'results_screen_viewed';
  static const String resultDetailViewed = 'result_detail_viewed';
  static const String resultShared = 'result_shared';
  static const String resultDeleted = 'result_deleted';

  // Scan Management Events
  static const String lowScansWarningShown = 'low_scans_warning_shown';
  static const String noScansError = 'no_scans_error';
  static const String scansRefreshed = 'scans_refreshed';

  // Package/Purchase Events
  static const String packagesScreenViewed = 'packages_screen_viewed';
  static const String packageSelected = 'package_selected';
  static const String purchaseStarted = 'purchase_started';
  static const String purchaseCompleted = 'purchase_completed';
  static const String purchaseFailed = 'purchase_failed';
  static const String purchaseCancelled = 'purchase_cancelled';

  // Profile Events
  static const String profileScreenViewed = 'profile_screen_viewed';
  static const String profileEditStarted = 'profile_edit_started';
  static const String profileUpdated = 'profile_updated';
  static const String profileUpdateFailed = 'profile_update_failed';
  static const String passwordChanged = 'password_changed';

  // Dashboard Events
  static const String dashboardViewed = 'dashboard_viewed';
  static const String statsRefreshed = 'stats_refreshed';

  // Navigation Events
  static const String screenViewed = 'screen_viewed';
  static const String buttonClicked = 'button_clicked';
  static const String linkClicked = 'link_clicked';

  // Error Events
  static const String errorOccurred = 'error_occurred';
  static const String apiError = 'api_error';
  static const String networkError = 'network_error';

  // Feature Usage
  static const String featureUsed = 'feature_used';
  static const String tutorialViewed = 'tutorial_viewed';
  static const String helpViewed = 'help_viewed';
}

class AnalyticsParameters {
  // User Parameters
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userPhone = 'user_phone';

  // Screen Parameters
  static const String screenName = 'screen_name';
  static const String screenClass = 'screen_class';
  static const String previousScreen = 'previous_screen';

  // Upload Parameters
  static const String imageSource = 'image_source';
  static const String imageSize = 'image_size';
  static const String uploadDuration = 'upload_duration';
  static const String consentGiven = 'consent_given';

  // Analysis Parameters
  static const String analysisId = 'analysis_id';
  static const String analysisScore = 'analysis_score';
  static const String analysisResult = 'analysis_result';
  static const String analysisDuration = 'analysis_duration';
  static const String aiDetected = 'ai_detected';
  static const String manipulationDetected = 'manipulation_detected';

  // Scan Parameters
  static const String remainingScans = 'remaining_scans';
  static const String scansUsed = 'scans_used';
  static const String maxScans = 'max_scans';

  // Package Parameters
  static const String packageId = 'package_id';
  static const String packageName = 'package_name';
  static const String packagePrice = 'package_price';
  static const String packageCurrency = 'package_currency';
  static const String packageScans = 'package_scans';
  static const String paymentMethod = 'payment_method';
  static const String transactionId = 'transaction_id';

  // Error Parameters
  static const String errorType = 'error_type';
  static const String errorMessage = 'error_message';
  static const String errorCode = 'error_code';
  static const String errorStack = 'error_stack';

  // Interaction Parameters
  static const String buttonName = 'button_name';
  static const String linkUrl = 'link_url';
  static const String actionType = 'action_type';
  static const String featureName = 'feature_name';

  // General Parameters
  static const String value = 'value';
  static const String success = 'success';
  static const String timestamp = 'timestamp';
  static const String duration = 'duration';
  static const String method = 'method';
}

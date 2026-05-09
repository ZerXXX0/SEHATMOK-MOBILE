import 'package:flutter/foundation.dart';

class AppConfig {
  // API Configuration
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000';
    }
  }
  
  static const int apiTimeout = 30; // seconds
  
  // Gemini API Configuration
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  static const String geminiModel = 'gemini-3-flash-preview';
  
  // Firebase Configuration
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );
  
  // Analytics Configuration
  static const String segmentWriteKey = String.fromEnvironment(
    'SEGMENT_WRITE_KEY',
    defaultValue: '',
  );
  
  // App Configuration
  static const String appName = 'SehatMok';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  
  // Cache Configuration
  static const int recipeCacheDays = 7;
  static const int fridgeDataCacheDays = 1;
  static const int recentSearchesCacheDays = 30;
  
  // Pagination
  static const int itemsPerPage = 25;
  static const int initialLoadSize = 50;
  
  // Timeouts
  static const Duration imageLoadTimeout = Duration(seconds: 10);
  static const Duration apiCallTimeout = Duration(seconds: 30);
  static const Duration dbOperationTimeout = Duration(seconds: 5);
  
  // Notification Configuration
  static const Duration expiryAlert1 = Duration(hours: 24);
  static const Duration expiryAlert2 = Duration(hours: 12);
  static const Duration expiryAlert3 = Duration(hours: 2);
  
  static void initialize() {
    // Initialize any required configuration
    // This can be expanded for different build flavors
  }
  
  // Environment-specific configurations
  static bool get isDevelopment =>
      apiBaseUrl.contains('localhost') ||
      apiBaseUrl.contains('192.168') ||
      apiBaseUrl.contains('10.0.2.2');
  
  static bool get isProduction =>
      apiBaseUrl.contains('api.sehatmok.com');
  
  static bool get isStaging =>
      apiBaseUrl.contains('staging-api.sehatmok.com');
}

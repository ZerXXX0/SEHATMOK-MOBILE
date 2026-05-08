class AppConstants {
  // App strings
  static const String appName = 'SehatMok';
  static const String appVersion = '1.0.0';

  // API endpoints
  static const String apiTimeoutMessage = 'Request timeout. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String unknownErrorMessage =
      'An unknown error occurred. Please try again.';

  // Storage keys
  static const String onboardingCompleted = 'onboarding_completed';
  static const String isDarkMode = 'is_dark_mode';
  static const String selectedLanguage = 'selected_language';

  // Timing constants
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

  // Food categories
  static const List<String> foodCategories = [
    'Vegetables',
    'Fruits',
    'Proteins',
    'Dairy',
    'Grains',
    'Spices',
    'Oils',
    'Other',
  ];

  // Activity levels
  static const List<String> activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];

  // Difficulty levels
  static const List<String> difficultyLevels = [
    'Easy',
    'Medium',
    'Hard',
  ];

  // Meal slots
  static const List<String> mealSlots = [
    'Breakfast',
    'Lunch',
    'Dinner',
  ];
}

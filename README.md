# SehatMok Mobile

A comprehensive health and nutrition management mobile application built with Flutter. Access all SehatMok features on iOS, Android, and more.

## Features

- **User Authentication** - Secure JWT-based login and registration
- **Digital Fridge** - Track your ingredients with expiry dates
- **Recipe Recommendations** - AI-powered suggestions based on available items
- **Meal Planning** - Plan your meals for breakfast, lunch, and dinner
- **Grocery Lists** - Manage your shopping lists
- **Nutrition Tracking** - Log your meals and track daily intake
- **Offline Support** - Use the app even without internet connection
- **Push Notifications** - Get alerts for expiring items and meal reminders

## Getting Started

### Prerequisites

- Flutter SDK: 3.11.5 or higher
- Dart SDK: 3.11.5 or higher
- Android Studio / Xcode (for platform-specific testing)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd sehatmok_mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build
```

4. Configure environment:
- Create `.env` file with API base URL and Firebase configuration
- Update `lib/config/app_config.dart` with your settings

### Running the App

**Development:**
```bash
flutter run -d <device-id>
```

**Debug Build:**
```bash
flutter run --debug
```

**Release Build:**
```bash
flutter run --release
```

### Building for Release

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## Project Structure

```
lib/
├── config/               # App configuration and constants
├── core/                 # Core utilities and extensions
├── features/             # Feature-specific code
│   ├── auth/            # Authentication screens
│   ├── home/            # Home/Dashboard
│   ├── fridge/          # Fridge management
│   ├── recipes/         # Recipe browsing and details
│   ├── meal_plans/      # Meal planning
│   ├── grocery/         # Grocery list management
│   ├── profile/         # User profile
│   └── nutrition/       # Nutrition tracking
├── models/              # Data models
├── services/            # API and local services
├── utils/               # Helper functions and utilities
├── widgets/             # Reusable widgets
└── main.dart            # App entry point
```

## Testing

Run tests with:
```bash
flutter test
```

For coverage:
```bash
flutter test --coverage
```

## Environment Configuration

Create `.env` file in the root directory:

```env
API_BASE_URL=https://api.sehatmok.com
API_TIMEOUT=30
GEMINI_API_KEY=your-api-key
FIREBASE_PROJECT_ID=your-project-id
SEGMENT_WRITE_KEY=your-segment-key
```

## Flavor Management

The app supports multiple flavors (dev, staging, prod):

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

## Database

The app uses SQLite for local data storage and Shared Preferences for app settings.

**Clear local database:**
```bash
flutter run --dart-define=CLEAR_DB=true
```

## Performance

- Target memory usage: < 50 MB at runtime
- Target APK size: < 50 MB
- Cold start time: < 3 seconds
- Warm start time: < 1 second

## Security

- JWT tokens stored in secure storage
- HTTPS/TLS for all API communications
- Certificate pinning enabled
- No hardcoded credentials

## Contributing

1. Create a feature branch: `git checkout -b feature/feature-name`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/feature-name`
4. Submit pull request

## Code Standards

- Follow Dart style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Write tests for critical functions
- Run analysis: `flutter analyze`

## Debugging

**Enable verbose logging:**
```bash
flutter run -v
```

**Connect to device:**
```bash
flutter devices
```

**Hot Reload:**
```
Press 'r' in the terminal
```

**Hot Restart:**
```
Press 'R' in the terminal
```

## Dependencies

Key dependencies:
- **dio**: HTTP client
- **provider**: State management
- **sqflite**: Local database
- **firebase_messaging**: Push notifications
- **cached_network_image**: Image caching
- **intl**: Internationalization

For complete list, see `pubspec.yaml`

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support

For support, email support@sehatmok.com or create an issue on GitHub.

## Changelog

### Version 1.0.0
- Initial release
- Core features implemented
- iOS and Android support

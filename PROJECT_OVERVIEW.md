# SEHATMOK MOBILE - PROJECT OVERVIEW

## Project Description
SehatMok Mobile is a comprehensive health and nutrition management Flutter application designed to work seamlessly with the SehatMok Web backend. The app helps users track their dietary intake, manage ingredients, receive AI-powered recipe recommendations, and plan meals for better nutrition.

## Project Status: ✓ STRUCTURE COMPLETE

This project has been scaffolded according to the PRD specifications. The directory structure, core files, services, models, and basic UI screens have been created and are ready for further development.

## Technology Stack

### Frontend Framework
- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language (v3.11.5+)

### State Management
- **Provider**: For reactive state management

### Networking & API
- **Dio**: Advanced HTTP client with interceptors
- **JWT**: Authentication with secure token storage

### Local Storage
- **SQLite** (sqflite): Local database
- **SharedPreferences**: Key-value storage
- **FlutterSecureStorage**: Secure credential storage

### UI & Design
- **Material Design 3**: Latest Material Design system
- **Tailwind CSS Inspired**: Color scheme from HTML mockups
- **Cached Network Image**: Image optimization

### Firebase Services
- **Firebase Core**: Firebase initialization
- **Firebase Messaging**: Push notifications
- **Firebase Analytics**: User behavior tracking

### Development & Testing
- **Flutter Lints**: Code quality
- **Build Runner**: Code generation
- **Mockito**: Unit testing

## Project Structure

```
sehatmok_mobile/
├── lib/
│   ├── config/                    # Configuration files
│   │   ├── app_config.dart        # App constants and settings
│   │   └── theme.dart             # Material Design 3 theme
│   │
│   ├── core/                      # Core utilities
│   │   ├── constants.dart         # App-wide constants
│   │   └── extensions.dart        # Dart extensions
│   │
│   ├── features/                  # Feature modules
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── models/            # [To be created]
│   │   │   └── providers/         # [To be created]
│   │   │
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   ├── models/            # [To be created]
│   │   │   └── providers/         # [To be created]
│   │   │
│   │   ├── fridge/
│   │   │   ├── screens/           # [To be created]
│   │   │   ├── models/            # [To be created]
│   │   │   └── providers/         # [To be created]
│   │   │
│   │   ├── recipes/
│   │   │   ├── screens/           # [To be created]
│   │   │   ├── models/            # [To be created]
│   │   │   └── providers/         # [To be created]
│   │   │
│   │   ├── meal_plans/            # [To be created]
│   │   ├── grocery/               # [To be created]
│   │   ├── profile/               # [To be created]
│   │   └── nutrition/             # [To be created]
│   │
│   ├── models/                    # Data models
│   │   ├── user_model.dart
│   │   ├── fridge_item_model.dart
│   │   ├── recipe_model.dart
│   │   ├── grocery_item_model.dart
│   │   └── meal_plan_model.dart
│   │
│   ├── services/                  # Service layer
│   │   ├── api_service.dart       # HTTP client
│   │   ├── auth_service.dart      # Authentication
│   │   ├── storage_service.dart   # Local storage
│   │   ├── fridge_service.dart    # Fridge management
│   │   ├── recipe_service.dart    # Recipe operations
│   │   ├── grocery_service.dart   # [To be created]
│   │   ├── meal_plan_service.dart # [To be created]
│   │   └── notification_service.dart # [To be created]
│   │
│   ├── utils/                     # Utilities
│   │   ├── validators.dart        # [To be created]
│   │   ├── formatters.dart        # [To be created]
│   │   └── helpers.dart           # [To be created]
│   │
│   ├── widgets/                   # Reusable widgets
│   │   ├── common_widgets.dart
│   │   ├── nutrition_card.dart    # [To be created]
│   │   ├── recipe_card.dart       # [To be created]
│   │   ├── fridge_item_card.dart  # [To be created]
│   │   └── meal_slot_widget.dart  # [To be created]
│   │
│   └── main.dart                  # App entry point
│
├── test/
│   ├── unit/                      # [To be created]
│   ├── widget/                    # [To be created]
│   └── integration/               # [To be created]
│
├── pubspec.yaml                   # Dependencies and config
├── README.md                      # Project documentation
├── SETUP_CHECKLIST.md            # Setup and completion checklist
├── .env.example                   # Environment variables template
├── .gitignore                     # Git ignore rules
├── analysis_options.yaml          # Linter configuration
└── .metadata                      # Flutter project metadata
```

## Core Features Implemented

### ✓ Authentication System
- Login screen with email/password
- Registration with validation
- JWT token management
- Secure token storage
- Session persistence

### ✓ Navigation Structure
- Bottom navigation with 5 main sections
- Feature-based navigation
- Auth wrapper for protected routes

### ✓ Dashboard/Home Screen
- Greeting with time-based messaging
- Today's nutrition summary card
- Quick action buttons (4 actions)
- Progress indicators for calorie tracking
- Macro breakdown display

### ✓ Theming System
- Material Design 3 color scheme
- Light and dark themes
- Custom typography (Manrope, Inter fonts)
- Responsive design patterns
- Custom component styling

### ✓ Service Layer Architecture
- API service with Dio client
- Error handling and logging
- Authentication service
- Storage service for local data
- Fridge service (CRUD operations)
- Recipe service with recommendations

### ✓ Data Models with JSON Serialization
- User model with profile data
- Fridge item model with expiry tracking
- Recipe model with nutrition info
- Grocery item model
- Meal plan model

### ✓ Reusable Components
- Loading overlay widget
- Error and success banners
- Empty state widget
- Section header widget
- Common UI patterns

### ✓ Code Quality & Standards
- Comprehensive linting rules
- Code analysis configuration
- Extension methods for common operations
- Constants file for app-wide values
- Structured error handling

## Features To Be Completed

### Screens & UI (Priority 1)
- [ ] Fridge management screen (list, add, edit, delete)
- [ ] Recipe browsing screen with search/filter
- [ ] Recipe details screen
- [ ] Recipe recommendations view
- [ ] Meal planning calendar interface
- [ ] Grocery list management screen
- [ ] User profile and settings screen
- [ ] Nutrition tracking dashboard

### Services (Priority 1)
- [ ] Grocery service
- [ ] Meal plan service
- [ ] Nutrition tracking service
- [ ] Notification service
- [ ] Local database service

### Advanced Features (Priority 2)
- [ ] Offline data synchronization
- [ ] Push notification setup
- [ ] Firebase analytics integration
- [ ] Image caching strategy
- [ ] AI recipe generation UI
- [ ] Barcode scanning
- [ ] Voice input for food logging

### Testing (Priority 2)
- [ ] Unit tests for services
- [ ] Widget tests for screens
- [ ] Integration tests
- [ ] Performance testing
- [ ] API mock testing

### Platform-Specific (Priority 3)
- [ ] Android native setup
- [ ] iOS native setup
- [ ] Web platform setup
- [ ] Desktop platform support
- [ ] Platform-specific permissions

### Documentation (Priority 3)
- [ ] Component storybook
- [ ] API documentation
- [ ] Architecture guide
- [ ] Contribution guidelines
- [ ] Troubleshooting guide

## Connected HTML Frontend
The mobile app UI is designed to complement the existing HTML/Tailwind designs in the "New Folder":
- **AI_Recipe_Generator.html**: Maps to AI recipe generation screen
- **Recipe_Details.html**: Maps to recipe details view
- **Digital_Refrigerator.html**: Maps to fridge management
- **Nutrition_Dashboard.html**: Maps to nutrition tracking
- **Color scheme and design language**: Consistent Material Design 3 styling

## Getting Started

### Prerequisites
- Flutter SDK 3.11.5+
- Dart SDK 3.11.5+
- Android SDK (for Android development)
- Xcode (for iOS development)
- VS Code or Android Studio

### Installation

1. **Navigate to project directory**
   ```bash
   cd sehatmok_mobile
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build
   ```

4. **Create .env file**
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Development Commands

```bash
# Watch for changes (hot reload)
flutter run -v

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Build release APK
flutter build apk --release

# Build release IPA
flutter build ios --release

# Build web
flutter build web --release
```

## API Integration

The app connects to the SehatMok Web backend with the following endpoints:

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user

### Profile
- `GET /api/profile` - Get user profile
- `PUT /api/profile` - Update user profile

### Fridge
- `GET /api/fridge` - List fridge items
- `POST /api/fridge` - Add fridge item
- `PUT /api/fridge/:id` - Update fridge item
- `DELETE /api/fridge/:id` - Delete fridge item

### Recipes
- `GET /api/recipes` - List recipes
- `GET /api/recipes/:id` - Get recipe details
- `POST /api/recommendations` - Get recommendations
- `POST /api/ai/generate-recipe` - Generate with AI

### Meal Plans
- `GET /api/meal-plans` - List meal plans
- `POST /api/meal-plans` - Create meal plan

### Grocery
- `GET /api/grocery` - List grocery items
- `POST /api/grocery` - Add grocery item

### Nutrition
- `GET /api/logs` - Get nutrition logs
- `POST /api/logs` - Create nutrition log

### Dashboard
- `GET /api/dashboard/summary` - Get summary stats

## Configuration

### Environment Variables (.env)
```
API_BASE_URL=http://localhost:3000
API_TIMEOUT=30
GEMINI_API_KEY=your-key
FIREBASE_PROJECT_ID=your-project
FIREBASE_API_KEY=your-key
FIREBASE_APP_ID=your-app-id
SEGMENT_WRITE_KEY=your-key
FLAVOR=dev
ENABLE_OFFLINE_MODE=true
ENABLE_PUSH_NOTIFICATIONS=true
ENABLE_ANALYTICS=true
```

### Theme Customization
Edit `lib/config/theme.dart` to customize colors, typography, and component styles.

### API Configuration
Edit `lib/config/app_config.dart` to modify API endpoints, timeouts, and feature flags.

## Architecture & Patterns

### Clean Architecture
- **Presentation Layer**: Screens and widgets
- **Domain Layer**: Models and interfaces (via services)
- **Data Layer**: API service, storage service, database

### State Management
- Provider for reactive state updates
- Service locator pattern for dependency injection
- Local state with StatefulWidget

### Error Handling
- Try-catch with specific error types
- Error logging with Logger
- User-friendly error messages
- Retry mechanisms

### Networking
- Dio with interceptors for request/response logging
- Automatic request timeout handling
- Error handling with custom messages
- Bearer token authentication

## Performance Targets
- Cold start time: < 3 seconds
- Warm start time: < 1 second
- Target APK size: < 50 MB
- Memory usage: < 50 MB at runtime
- Frame rate: 60 FPS

## Security Features
- JWT tokens stored in secure storage
- HTTPS/TLS for all API communication
- Certificate pinning ready
- No hardcoded credentials
- Secure device storage for tokens

## Testing Strategy

### Unit Tests
- Test service methods
- Test model serialization
- Test utility functions

### Widget Tests
- Test screen layouts
- Test form validation
- Test button interactions

### Integration Tests
- Complete authentication flow
- Fridge CRUD operations
- Recipe recommendation flow

## Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Troubleshooting

### Build Issues
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Runtime Issues
```bash
flutter run -v  # Verbose logging
flutter doctor  # Check environment setup
```

### Performance Issues
- Check API response times
- Monitor image loading
- Profile memory usage with DevTools
- Check for UI jank with Inspector

## Contributing

1. Follow Dart/Flutter style guidelines
2. Write meaningful commit messages
3. Add tests for new features
4. Update documentation
5. Run analysis before committing

## Future Enhancements

- Barcode scanning for ingredients
- Voice-based food logging
- Social recipe sharing
- Integration with fitness trackers
- Wearable app support
- Advanced analytics
- Machine learning recommendations

## Support & Documentation

- [Flutter Documentation](https://flutter.dev)
- [Dart Documentation](https://dart.dev)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio HTTP Client](https://pub.dev/packages/dio)

## License

This project is licensed under the MIT License.

## Contact

For support, contact: support@sehatmok.com

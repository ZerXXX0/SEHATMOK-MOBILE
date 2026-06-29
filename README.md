# SehatMok Mobile

A comprehensive health and nutrition management mobile application built with Flutter. Access all SehatMok features on iOS, Android, and Web platforms.

## Core Features & Capabilities

- **User Authentication** - Secure JWT-based login and registration.
- **🔐 Biometric Authentication** - Fully integrated fingerprint & Face ID login with secure credentials caching.
- **Digital Fridge** - Track ingredients with expiry dates, warning indicators, and category filtering.
- **Recipe Recommendations** - AI-powered suggestions based on your available fridge items.
- **Meal Planning** - Organize meals for breakfast, lunch, and dinner slots.
- **Grocery Lists** - Track shopping items and active lists.
- **Nutrition Tracking** - Log calorie intake, macros (protein, carbs, fats), and monitor daily targets.
- **Session Pre-Fetching** - Pre-loads profile data on launch to avoid UI flicker or empty templates.
- **Offline Support** - SQLite local database caching and session persistence.
- **Push Notifications** - Custom alerts for expiring items and meal reminders.

---

## Core Architecture & Recent Enhancements

### 🔐 Biometric Authentication Flow
The app includes a biometric authentication system powered by the `local_auth` package and device-level hardware-backed secure storage.

* **How it works**:
  1. **Enabling**: Biometric login defaults to **"enabled"** for all users once a successful manual credentials check completes.
  2. **Security**: Credentials (email and password) are encrypted and stored in the device's hardware enclave (Android Keystore / iOS Keychain) via `StorageService`.
  3. **Verification**: When launching the app or returning, the OS interceptor prompts the user for authentication. If successful, the app securely retrieves the credentials in the background to automatically log in.
* **Important Policy**:
  - **Device-wide Validation**: Authentication verification is delegated entirely to the operating system's native API. The application does not store or process raw biometrics. Any fingerprint or Face ID registered in the device's main system settings is valid for authentication.
  - **App-User Association**: The device biometric verification unlocks the specific account profile currently saved in the local secure enclave. Logging out or logging in as another user updates this link.

### ⚡ Session Hydration & Performance
* **Profile Pre-fetching**: The app startup check `isUserLoggedIn()` automatically triggers and awaits the profile retrieval (`getCurrentUser()`) upon token validation. This avoids UI flickering or empty user avatar skeletons when transitioning to the homepage.
* **Cached Avatar Loading**: Network avatars use `CachedNetworkImage` with a circular `ClipOval` container. It handles offline caching automatically and presents clean, native profile silhouette icons when the user has not set an avatar or is offline.

### 📱 Simplified Navigation Layout
To reduce navigation clutter on smaller screens, the bottom navigation bar has been simplified from 7 items down to **5 primary tabs**:
1. **Home** (`DashboardView`)
2. **Fridge** (`FridgeView`)
3. **Recipes** (`RecipesView`)
4. **Meals** (`MealPlansView`)
5. **Profile** (`ProfileView`)

* **Direct Shortcuts**:
  - **Calorie Logs**: Pushed directly from the homepage by clicking the **Today's Nutrition (Logs)** card.
  - **Grocery List**: Pushed directly from the homepage by clicking the **Grocery** card under the Overview section.
  - Sub-pages automatically refresh dashboard metrics on return.

---

## Getting Started & Quick Start Guide

### Prerequisites
- **Flutter SDK**: 3.11.5 or higher
- **Dart SDK**: 3.11.5 or higher
- **Android Studio / Xcode** (for platform-specific emulators and testing tools)

### 5-Minute Installation & Run

1. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Generate Code (Models & JSON Serialization)**:
   ```bash
   flutter pub run build_runner build
   ```
   *For live regeneration during development, run:*
   ```bash
   flutter pub run build_runner watch
   ```

3. **Configure Environment**:
   Copy `.env.example` to `.env` and set your API base URL and Gemini key:
   ```bash
   cp .env.example .env
   ```
   *Note: If no `API_BASE_URL` is defined, the app defaults to `http://10.0.2.2:3000` on Android emulator to connect to your host machine's Next.js dev server.*

4. **Launch the App**:
   ```bash
   # Run on default connected device/emulator
   flutter run --dart-define-from-file=.env
   
   # Run with a custom API base URL directly (without .env file)
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
   ```

---

## Project Structure & File Map

```
lib/
├── main.dart              # App entry point & main router
├── config/                # App configuration, theme, and styling
│   ├── theme.dart         # Material Design 3 colors, fonts & theme modes
│   └── app_config.dart    # API base URLs, timeouts, and configuration flags
├── core/                  # Core constants and framework extensions
│   ├── constants.dart     # App-wide constants
│   └── extensions.dart    # Dart utility extensions
├── features/              # Feature modules (UI Screens, widgets, state management)
│   ├── auth/              # Login, registration, and onboarding screens
│   ├── home/              # Main dashboard and navigation shell
│   ├── fridge/            # Digital fridge management
│   ├── recipes/           # Recipe discovery and recommendations
│   ├── meal_plans/        # Meal planning slots
│   ├── grocery/           # Grocery item list
│   └── profile/           # User settings & profile customisation
├── models/                # JSON-serializable data models
├── services/              # API Client (Dio) and local caching services
└── widgets/               # Reusable presentation widgets
```

---

## Development Workflow & Commands

### Running in Different Flavors
```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

### Static Analysis & Formatting
```bash
# Check code for issues
flutter analyze

# Format code
dart format lib/

# Apply automated fixes
dart fix --apply
```

### Testing
```bash
# Run all unit and widget tests
flutter test

# Run a specific test file
flutter test test/services/auth_service_test.dart

# Generate test coverage report
flutter test --coverage
```

### Cleaning Build Cache
If you encounter weird caching, compilation, or Gradle build errors:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Backend API Endpoints

The mobile client interacts with the Next.js backend via the following `/api` endpoints:

| Feature | Method & Endpoint | Description |
|---|---|---|
| **Auth** | `POST /api/auth/register` | Register a new user |
| **Auth** | `POST /api/auth/login` | Login user and obtain JWT |
| **Auth** | `POST /api/auth/logout` | Invalidate current session |
| **Profile** | `GET /api/profile` | Fetch user profile data |
| **Profile** | `PUT /api/profile` | Update name, avatar or metrics |
| **Fridge** | `GET /api/fridge` | List current fridge ingredients |
| **Fridge** | `POST /api/fridge` | Add a new ingredient item |
| **Fridge** | `PUT /api/fridge/:id` | Update quantity / expiry date |
| **Fridge** | `DELETE /api/fridge/:id` | Delete an ingredient item |
| **Recipes** | `GET /api/recipes` | Search & browse curated recipes |
| **Recipes** | `GET /api/recipes/:id` | Get individual recipe details |
| **Recipes** | `POST /api/recommendations` | Get fridge-aware recommendations |
| **Recipes** | `POST /api/ai/generate-recipe` | Generate a dynamic recipe via Gemini |
| **Meals** | `GET /api/meal-plans` | Retrieve meal plans calendar |
| **Meals** | `POST /api/meal-plans` | Add recipe to meal slot |
| **Grocery** | `GET /api/grocery` | Fetch grocery shopping items |
| **Grocery** | `POST /api/grocery` | Add item to grocery list |
| **Nutrition**| `GET /api/logs` | Fetch nutrition intake history |
| **Nutrition**| `POST /api/logs` | Log meal consumption/calories |
| **Dashboard**| `GET /api/dashboard/summary` | Fetch dashboard counts & status |

---

## Environment Configuration (`.env`)

Create a `.env` file in the `mobile` directory using the following template:
```env
API_BASE_URL=https://api.sehatmok.com
API_TIMEOUT=30
GEMINI_API_KEY=your-gemini-key
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-firebase-key
FIREBASE_APP_ID=your-app-id
SEGMENT_WRITE_KEY=your-segment-write-key
FLAVOR=dev
ENABLE_OFFLINE_MODE=true
ENABLE_PUSH_NOTIFICATIONS=true
ENABLE_ANALYTICS=true
```

---

## IDE Integration Tips

### Recommended Extensions
* **VS Code**:
  - `Flutter` & `Dart`
  - `Flutter Widget Snippets`
  - `Awesome Flutter Snippets`
* **Android Studio**:
  - `Flutter` & `Dart` plugins

### Useful Shortcuts
| Action | VS Code | Android Studio |
|---|---|---|
| **Toggle terminal** | `Ctrl + J` | `Alt + F12` |
| **Command Palette** | `Ctrl + Shift + P` | `Ctrl + Shift + A` |
| **Hot Reload** | Save file or `r` in console | `Ctrl + Alt + R` |
| **Hot Restart** | `R` in console | `Ctrl + Alt + Shift + R` |
| **Open DevTools** | `Ctrl + Shift + D` | `Ctrl + Alt + D` |

---

## Deployment & Release Build Commands

### Android
```bash
# Generate Release APK
flutter build apk --release

# Generate Android App Bundle (AAB for Google Play)
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

---

## Performance Targets

- **Cold Start Time**: < 3 seconds
- **Warm Start Time**: < 1 second
- **Memory Footprint**: < 50 MB at runtime
- **Target APK size**: < 50 MB
- **Frame Rate**: Stable 60 FPS

---

## License & Contact

- **License**: MIT License
- **Support Contact**: support@sehatmok.com

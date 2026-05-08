# SEHATMOK MOBILE - QUICK START GUIDE

## 5-Minute Setup

### 1. Prerequisites Check
```bash
# Verify Flutter is installed
flutter --version

# Check Flutter setup
flutter doctor

# Expected: All green except possibly iOS deployment target
```

### 2. Project Setup
```bash
# Navigate to project
cd sehatmok_mobile

# Get all dependencies
flutter pub get

# Generate code from models
flutter pub run build_runner build
```

### 3. Configuration
```bash
# Create environment file
cp .env.example .env

# Edit .env with your API endpoints
# Minimum required:
# API_BASE_URL=http://localhost:3000
```

### 4. Run the App
```bash
# Run on default device/emulator
flutter run

# Or specify device
flutter run -d <device-id>

# List available devices
flutter devices
```

## Project Structure at a Glance

```
lib/
├── main.dart              ← App entry point
├── config/
│   ├── theme.dart         ← Material Design 3 colors & typography
│   └── app_config.dart    ← API & feature configuration
├── core/
│   ├── constants.dart     ← App constants
│   └── extensions.dart    ← Useful extensions
├── features/              ← Feature screens & logic
├── models/                ← Data models (User, Recipe, etc)
├── services/              ← API & local storage
└── widgets/               ← Reusable UI components
```

## Key Files to Know

| File | Purpose |
|------|---------|
| `main.dart` | App entry point & routing |
| `config/theme.dart` | Colors, fonts, styling |
| `config/app_config.dart` | API URLs, constants |
| `services/api_service.dart` | HTTP client |
| `services/auth_service.dart` | Login/Register/Logout |
| `features/home/screens/home_screen.dart` | Main dashboard |

## Development Workflow

### Hot Reload Development
```bash
# Run app with watch mode
flutter run -v

# In terminal, press 'r' to reload
# Press 'R' to restart app
```

### Code Generation
```bash
# After modifying models
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch
```

### Code Analysis
```bash
# Check for issues
flutter analyze

# Format code
dart format lib/

# Fix common issues
dart fix lib/
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Generate coverage report
flutter test --coverage
```

## Common Tasks

### Add a New Dependency
```bash
flutter pub add package_name

# Or edit pubspec.yaml directly then
flutter pub get
```

### Create a New Feature Screen
1. Create folder: `lib/features/new_feature/screens/`
2. Create screen file: `new_feature_screen.dart`
3. Create model (if needed): `lib/models/new_feature_model.dart`
4. Create service (if needed): `lib/services/new_feature_service.dart`
5. Add route to `main.dart`
6. Add button/navigation to existing screen

### Debug the App
```bash
# Enable verbose logging
flutter run -v

# Open DevTools
flutter pub global activate devtools
devtools

# Inspect widgets (in another terminal)
dart devtools
```

### Build for Release

**Android:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS:**
```bash
flutter build ios --release
# Then upload via Xcode or use tools
```

## Debugging Common Issues

### "pubspec.yaml not found"
```bash
# Make sure you're in project root
ls pubspec.yaml

# If not found, you're in wrong directory
cd sehatmok_mobile
```

### "Analysis not finding my changes"
```bash
# Run build_runner to regenerate
flutter pub run build_runner build --delete-conflicting-outputs
```

### "API connection refused"
```bash
# Check API is running
# Check .env has correct API_BASE_URL
# For local: http://localhost:3000
# For emulator Android: http://10.0.2.2:3000
```

### "Hot reload not working"
```bash
# Do a hot restart instead
# Press 'R' in terminal
# Or stop and restart: flutter run
```

### "Gradle build fails"
```bash
# Clean everything
flutter clean

# Get fresh dependencies
flutter pub get

# Try building again
flutter run
```

### "CocoaPods error (iOS)"
```bash
# Update CocoaPods
cd ios
pod repo update
cd ..

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Environment Variables

The app uses `.env` file for configuration. Copy `.env.example`:

```bash
cp .env.example .env
```

Key variables:
- `API_BASE_URL` - Backend API endpoint
- `GEMINI_API_KEY` - Google AI API key
- `FIREBASE_PROJECT_ID` - Firebase project
- `FLAVOR` - Environment (dev, staging, prod)

## Testing the Features

### Test Login
1. Run app: `flutter run`
2. Tap "Sign Up" or enter test credentials
3. Email: `test@sehatmok.com`
4. Password: `password123`

### Test Dashboard
1. After login, see nutrition summary
2. Try quick action buttons (currently placeholders)
3. Bottom nav switches between screens

### Test Navigation
1. Tap bottom nav items
2. Each shows placeholder screen
3. Profile tab has logout button

## IDE Shortcuts

### VS Code
| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+D` | Open DevTools |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+J` | Toggle debug console |
| `F5` | Start debugging |

### Android Studio
| Shortcut | Action |
|----------|--------|
| `Shift+F10` | Run app |
| `Ctrl+Alt+D` | Open DevTools |
| `Ctrl+Alt+R` | Hot reload |
| `Ctrl+H` | Find and replace |

## Performance Tips

- Use `const` constructors where possible
- Avoid rebuilding entire widget tree
- Use `ListView.builder` for long lists
- Cache network images with `CachedNetworkImage`
- Profile with DevTools: `flutter pub global run devtools`

## Next Steps After Setup

1. **Connect to Backend**
   - Update API_BASE_URL in .env
   - Test API endpoints

2. **Build Fridge Screen**
   - See `lib/features/fridge/`
   - Implement item list with FridgeService
   - Add CRUD operations

3. **Build Recipe Screen**
   - See `lib/features/recipes/`
   - Implement recipe list with search
   - Add recommendation engine

4. **Add More Features**
   - Follow existing patterns
   - Use services for data
   - Reuse common widgets

5. **Test Everything**
   - Write unit tests
   - Test all screens
   - Test API integration

## Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Dart Guide**: https://dart.dev/guides
- **Material Design 3**: https://m3.material.io
- **Provider Package**: https://pub.dev/packages/provider
- **Dio HTTP**: https://pub.dev/packages/dio

## Tips & Tricks

### Quick Restart
Hold `R` in terminal for hot restart (more thorough than hot reload)

### View Widget Tree
In DevTools, click "Inspector" to see rendered widgets

### Check Performance
In DevTools, check "Performance" tab for frame timing

### View Network Requests
In DevTools, "Network" tab shows all API calls

### Save Your Work
```bash
git init
git add .
git commit -m "Initial Flutter project"
```

## Troubleshooting Checklist

- [ ] Flutter doctor shows all green
- [ ] pubspec.yaml is in root directory
- [ ] .env file exists with API_BASE_URL
- [ ] pubspec.yaml dependencies updated (`flutter pub get`)
- [ ] Code generated (`flutter pub run build_runner build`)
- [ ] Device/emulator is running and connected
- [ ] API backend is running and accessible
- [ ] No syntax errors (flutter analyze shows no errors)

## Getting Help

1. Check the error message carefully
2. Run: `flutter doctor -v`
3. Read Flutter documentation
4. Check official Flutter GitHub issues
5. Ask on Stack Overflow or Flutter Discord

## Happy Coding! 🚀

Start building with the flutter run command and reference this guide as needed.

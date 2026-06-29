import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/app_config.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/bookmark_service.dart';
import 'services/dashboard_service.dart';
import 'services/storage_service.dart';
import 'services/database_service.dart';
import 'services/fridge_service.dart';
import 'services/grocery_service.dart';
import 'services/hydration_service.dart';
import 'services/logs_service.dart';
import 'services/meal_plan_service.dart';
import 'services/recipe_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService.instance.initialize();
  await DatabaseService.instance.initialize();
  AppConfig.initialize();
  
  // FOR TESTING: Reset onboarding so welcome screen shows up on every restart.
  // Comment this line out in production.
  await StorageService.instance.removeAppPreference('has_seen_onboarding');
  
  runApp(const SehatMokApp());
}

class SehatMokApp extends StatelessWidget {
  const SehatMokApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(context.read<ApiService>()),
        ),
        Provider<DashboardService>(
          create: (context) => DashboardService(context.read<ApiService>()),
        ),
        Provider<FridgeService>(
          create: (context) => FridgeService(context.read<ApiService>()),
        ),
        Provider<RecipeService>(
          create: (context) => RecipeService(context.read<ApiService>()),
        ),
        Provider<MealPlanService>(
          create: (context) => MealPlanService(context.read<ApiService>()),
        ),
        Provider<GroceryService>(
          create: (context) => GroceryService(context.read<ApiService>()),
        ),
        Provider<HydrationService>(
          create: (context) => HydrationService(context.read<ApiService>()),
        ),
        Provider<LogsService>(
          create: (context) => LogsService(context.read<ApiService>()),
        ),
        Provider<BookmarkService>(
          create: (context) => BookmarkService(context.read<ApiService>()),
        ),
        Provider<StorageService>(
          create: (_) => StorageService.instance,
        ),
        Provider<DatabaseService>(
          create: (_) => DatabaseService.instance,
        ),
      ],
      child: MaterialApp(
        title: 'SehatMok',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    final hasSeenOnboarding = storage.getAppPreference('has_seen_onboarding') == true;

    return FutureBuilder<bool>(
      future: context.read<AuthService>().isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isLoggedIn = snapshot.data == true;

        if (isLoggedIn) {
          return const WelcomeScreen(isAlreadyLoggedIn: true);
        } else {
          if (!hasSeenOnboarding) {
            return const WelcomeScreen(isAlreadyLoggedIn: false);
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}

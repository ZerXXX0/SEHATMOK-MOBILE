import 'package:logger/logger.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  AuthService(this._apiService);

  // Register
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _logger.d('Registering user: $email');

      final response = await _apiService.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      final user = User.fromJson(response['user']);
      final token = response['token'];

      // Save token and user info
      await StorageService.instance.saveToken(token);
      await StorageService.instance.saveUserId(user.id);
      await StorageService.instance.saveUserEmail(user.email);

      _apiService.setAuthToken(token);

      _logger.d('User registered successfully: ${user.email}');
      return user;
    } catch (e) {
      _logger.e('Registration error: $e');
      rethrow;
    }
  }

  // Login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.d('Logging in user: $email');

      final response = await _apiService.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final user = User.fromJson(response['user']);
      final token = response['token'];

      // Save token and user info
      await StorageService.instance.saveToken(token);
      await StorageService.instance.saveUserId(user.id);
      await StorageService.instance.saveUserEmail(user.email);

      _apiService.setAuthToken(token);

      _logger.d('User logged in successfully: ${user.email}');
      return user;
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _logger.d('Logging out user');

      await _apiService.post('/api/auth/logout');

      // Clear local storage
      await StorageService.instance.logout();
      _apiService.removeAuthToken();

      _logger.d('User logged out successfully');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Still clear local storage even if API call fails
      await StorageService.instance.logout();
      _apiService.removeAuthToken();
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    try {
      final token = await StorageService.instance.getToken();
      if (token == null) return false;

      // Check if token is still valid
      return await StorageService.instance.hasValidToken();
    } catch (e) {
      _logger.e('Error checking login status: $e');
      return false;
    }
  }

  // Restore session
  Future<void> restoreSession() async {
    try {
      final token = await StorageService.instance.getToken();
      if (token != null) {
        _apiService.setAuthToken(token);
        _logger.d('Session restored');
      }
    } catch (e) {
      _logger.e('Error restoring session: $e');
    }
  }

  // Get current user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/api/profile');
      return User.fromJson(response);
    } catch (e) {
      _logger.e('Error getting current user: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? name,
    int? age,
    double? weight,
    double? height,
    String? activityLevel,
    int? targetCalories,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (age != null) data['age'] = age;
      if (weight != null) data['weight'] = weight;
      if (height != null) data['height'] = height;
      if (activityLevel != null) data['activityLevel'] = activityLevel;
      if (targetCalories != null) data['targetCalories'] = targetCalories;

      final response = await _apiService.put('/api/profile', data: data);
      return User.fromJson(response);
    } catch (e) {
      _logger.e('Error updating profile: $e');
      rethrow;
    }
  }
}

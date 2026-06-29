import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;
  final ApiService _apiService;
  final Logger _logger = Logger();

  AuthService(this._apiService);

  // Register
  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      _logger.d('Registering user: $email');

      final response = await _apiService.post(
        '/api/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'name': name?.trim() ?? '',
        },
      );

      if (response == null) {
        throw Exception('Server returned an empty response during registration.');
      }

      if (response is Map<String, dynamic> && response['success'] == false) {
        throw Exception(response['message'] ?? 'Registration failed.');
      }

      if (response['user'] == null) {
        throw Exception(response['message'] ?? 'Server response is missing user data.');
      }

      final user = User.fromJson(response['user']);
      final token = response['token'];

      // Save token and user info
      await StorageService.instance.saveToken(token);
      await StorageService.instance.saveUserId(user.id);
      await StorageService.instance.saveUserEmail(user.email);

      _apiService.setAuthToken(token);

      _currentUser = user;
      notifyListeners();

      if (name != null && name.trim().isNotEmpty) {
        final updated = await updateProfile(name: name.trim());
        _logger.d('User registered successfully: ${updated.email}');
        return updated;
      }

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
          'email': email.trim(),
          'password': password,
        },
      );

      if (response == null) {
        throw Exception('Server returned an empty response during login.');
      }

      if (response is Map<String, dynamic> && response['success'] == false) {
        throw Exception(response['message'] ?? 'Login failed.');
      }

      if (response['user'] == null) {
        throw Exception(response['message'] ?? 'Server response is missing user data.');
      }

      final user = User.fromJson(response['user']);
      final token = response['token'];

      // Save token and user info
      await StorageService.instance.saveToken(token);
      await StorageService.instance.saveUserId(user.id);
      await StorageService.instance.saveUserEmail(user.email);

      _apiService.setAuthToken(token);

      _currentUser = user;
      notifyListeners();

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

      _currentUser = null;
      notifyListeners();

      _logger.d('User logged out successfully');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Still clear local storage even if API call fails
      await StorageService.instance.logout();
      _apiService.removeAuthToken();
      _currentUser = null;
      notifyListeners();
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    try {
      final token = await StorageService.instance.getToken();
      if (token == null) return false;

      // Check if token is still valid
      final isValid = await StorageService.instance.hasValidToken();
      if (isValid) {
        _apiService.setAuthToken(token);
        // Pre-fetch user profile so currentUser is populated immediately
        try {
          await getCurrentUser();
        } catch (e) {
          _logger.w('Failed to pre-fetch user profile on login check: $e');
        }
      }
      return isValid;
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
      if (response == null) {
        throw Exception('Server returned an empty profile response.');
      }
      final user = User.fromJson(response);
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      _logger.e('Error getting current user: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? name,
    String? avatarUrl,
    int? age,
    double? weight,
    double? height,
    String? activityLevel,
    int? targetCalories,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (age != null) data['age'] = age;
      if (weight != null) data['weight'] = weight;
      if (height != null) data['height'] = height;
      if (activityLevel != null) data['activityLevel'] = activityLevel;
      if (targetCalories != null) data['targetCalories'] = targetCalories;

      if (data.isEmpty) {
        throw Exception('No profile fields provided for update.');
      }

      final response = await _apiService.put('/api/profile', data: data);
      if (response == null) {
        throw Exception('Server returned an empty update profile response.');
      }
      final user = User.fromJson(response);
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      _logger.e('Error updating profile: $e');
      rethrow;
    }
  }

  // Upload avatar and return the uploaded avatarUrl
  Future<String> uploadAvatar({required String filePath}) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('Avatar file not found.');
      }

      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path),
      });

      final response = await _apiService.postMultipart(
        '/api/profile/avatar',
        data: formData,
      );

      if (response is Map<String, dynamic> && response['avatarUrl'] is String) {
        return response['avatarUrl'] as String;
      }

      throw Exception('Invalid avatar upload response.');
    } catch (e) {
      _logger.e('Avatar upload error: $e');
      rethrow;
    }
  }
}

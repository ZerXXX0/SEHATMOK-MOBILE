import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static StorageService get instance => _instance;

  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;
  final Logger _logger = Logger();

  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
    _logger.d('StorageService initialized');
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    _logger.d('Token saved');
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> removeToken() async {
    await _secureStorage.delete(key: _tokenKey);
    _logger.d('Token removed');
  }

  Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  // User Info
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await _prefs.setString(_emailKey, email);
  }

  String? getUserEmail() {
    return _prefs.getString(_emailKey);
  }

  // App Preferences
  Future<void> setAppPreference(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  dynamic getAppPreference(String key) {
    return _prefs.get(key);
  }

  Future<void> removeAppPreference(String key) async {
    await _prefs.remove(key);
  }

  // Clear All
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
    _logger.d('All storage cleared');
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_emailKey);
    _logger.d('User logged out');
  }
}

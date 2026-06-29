import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';

class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'API Response: ${response.statusCode} '
            '${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            'API Error: ${error.message} (Type: ${error.type}, Error: ${error.error}) (${error.requestOptions.uri})',
          );
          return handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final Logger _logger = Logger();

  // Set authorization header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization header
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<T> put<T>(
    String path, {
    Object? data,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        options: options,
      );
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST multipart request
  Future<T> postMultipart<T>(
    String path, {
    required FormData data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    var message = 'An error occurred';
    final statusCode = error.response?.statusCode;
    dynamic details;

    if (error.response != null) {
      final data = error.response?.data;
      details = data;
      if (data is Map<String, dynamic>) {
        if (data['message'] is String) {
          message = data['message'] as String;
        } else if (data['error'] is String) {
          message = data['error'] as String;
        } else {
          message = 'Server error: ${error.response?.statusCode}';
        }
      } else {
        message = 'Server error: ${error.response?.statusCode}';
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Server response timeout. Please try again later.';
    } else if (error.type == DioExceptionType.sendTimeout) {
      message = 'Request send timeout. Please try again.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Could not connect to server. Please ensure the backend is running.';
    } else if (error.type == DioExceptionType.badCertificate) {
      message = 'Secure connection failed (bad certificate).';
    } else if (error.type == DioExceptionType.cancel) {
      message = 'Request was cancelled.';
    } else {
      final err = error.error;
      if (err is SocketException) {
        message = 'No internet connection or server is unreachable.';
      } else if (err != null && err.toString().contains('SocketException')) {
        message = 'No internet connection or server is unreachable.';
      } else {
        message = error.message ?? 'An unexpected network error occurred.';
      }
    }

    _logger.e('API Error: $message (Status: $statusCode)');
    return ApiException(message, statusCode: statusCode, details: details);
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final dynamic details;

  @override
  String toString() => message;
}

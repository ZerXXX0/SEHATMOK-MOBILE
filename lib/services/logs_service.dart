import 'package:logger/logger.dart';

import '../models/nutrition_log_model.dart';
import 'api_service.dart';

class LogsService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  LogsService(this._apiService);

  Future<List<NutritionLog>> getLogs({String? type}) async {
    try {
      _logger.d('Fetching nutrition logs');
      final response = await _apiService.get(
        '/api/logs',
        queryParameters: {
          if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
        },
      );

      return (response as List)
          .map((item) => NutritionLog.fromJson(item))
          .toList();
    } catch (e) {
      _logger.e('Error fetching nutrition logs: $e');
      rethrow;
    }
  }

  Future<NutritionLog> addLog({
    required String type,
    required int calories,
  }) async {
    try {
      _logger.d('Creating nutrition log');

      final response = await _apiService.post(
        '/api/logs',
        data: {
          'type': type,
          'calories': calories,
        },
      );

      return NutritionLog.fromJson(response);
    } catch (e) {
      _logger.e('Error creating nutrition log: $e');
      rethrow;
    }
  }
}

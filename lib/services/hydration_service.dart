import 'package:logger/logger.dart';

import '../models/hydration_model.dart';
import 'api_service.dart';

class HydrationService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  HydrationService(this._apiService);

  Future<HydrationSummary> getHydration({String? date}) async {
    try {
      _logger.d('Fetching hydration summary');
      final response = await _apiService.get(
        '/api/hydration',
        queryParameters: {
          if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
        },
      );

      return HydrationSummary.fromJson(response);
    } catch (e) {
      _logger.e('Error fetching hydration summary: $e');
      rethrow;
    }
  }

  Future<HydrationSummary> updateHydration({
    String? date,
    int? deltaMl,
    int? amountMl,
    int? targetMl,
  }) async {
    try {
      _logger.d('Updating hydration log');

      final response = await _apiService.post(
        '/api/hydration',
        data: {
          if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
          if (deltaMl != null) 'deltaMl': deltaMl,
          if (amountMl != null) 'amountMl': amountMl,
          if (targetMl != null) 'targetMl': targetMl,
        },
      );

      return HydrationSummary.fromJson(response);
    } catch (e) {
      _logger.e('Error updating hydration log: $e');
      rethrow;
    }
  }
}

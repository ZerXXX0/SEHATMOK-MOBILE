import 'package:logger/logger.dart';

import '../models/dashboard_summary_model.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  DashboardService(this._apiService);

  Future<DashboardSummary> getSummary() async {
    try {
      _logger.d('Fetching dashboard summary');
      final response = await _apiService.get('/api/dashboard/summary');
      return DashboardSummary.fromJson(response);
    } catch (e) {
      _logger.e('Error fetching dashboard summary: $e');
      rethrow;
    }
  }
}

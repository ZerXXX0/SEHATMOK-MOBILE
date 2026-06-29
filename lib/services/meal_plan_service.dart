import 'package:logger/logger.dart';

import '../models/meal_plan_model.dart';
import 'api_service.dart';

class MealPlanService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  MealPlanService(this._apiService);

  Future<MealPlanDay> getMealPlans({required String date}) async {
    try {
      _logger.d('Fetching meal plans');
      final response = await _apiService.get(
        '/api/meal-plans',
        queryParameters: {'date': date},
      );

      return MealPlanDay.fromJson(response);
    } catch (e) {
      _logger.e('Error fetching meal plans: $e');
      rethrow;
    }
  }

  Future<MealPlanItem> upsertMealPlan({
    required String date,
    required String slot,
    required String recipeId,
  }) async {
    try {
      _logger.d('Upserting meal plan');

      final response = await _apiService.post(
        '/api/meal-plans',
        data: {
          'date': date,
          'slot': slot,
          'recipeId': recipeId,
        },
      );

      return MealPlanItem.fromJson(response);
    } catch (e) {
      _logger.e('Error upserting meal plan: $e');
      rethrow;
    }
  }

  Future<void> deleteMealPlanSlot({
    required String date,
    required String slot,
  }) async {
    try {
      _logger.d('Deleting meal plan slot');

      await _apiService.delete(
        '/api/meal-plans',
        data: {
          'date': date,
          'slot': slot,
        },
      );
    } catch (e) {
      _logger.e('Error deleting meal plan slot: $e');
      rethrow;
    }
  }

  Future<void> deleteMealPlanItem(String id) async {
    try {
      _logger.d('Deleting meal plan item');
      await _apiService.delete('/api/meal-plans/$id');
    } catch (e) {
      _logger.e('Error deleting meal plan item: $e');
      rethrow;
    }
  }
}

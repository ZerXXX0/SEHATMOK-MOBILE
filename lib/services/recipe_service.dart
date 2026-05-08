import 'package:logger/logger.dart';
import '../models/recipe_model.dart';
import 'api_service.dart';
import 'database_service.dart';

class RecipeService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  RecipeService(this._apiService);

  // Get all recipes
  Future<List<Recipe>> getRecipes({
    int page = 1,
    int limit = 25,
  }) async {
    try {
      _logger.d('Fetching recipes');

      final response = await _apiService.get(
        '/api/recipes',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();

      _logger.d('Fetched ${recipes.length} recipes');
      try {
        await DatabaseService.instance.upsertRecipes(recipes);
      } catch (_) {}
      return recipes;
    } catch (e) {
      _logger.e('Error fetching recipes: $e');
      // Fallback to cached recipes
      try {
        final cached = await DatabaseService.instance.getRecipes();
        if (cached.isNotEmpty) return cached;
      } catch (_) {}
      rethrow;
    }
  }

  // Get recipe details
  Future<Recipe> getRecipeDetails(String id) async {
    try {
      _logger.d('Fetching recipe details: $id');

      final response = await _apiService.get('/api/recipes/$id');
      final recipe = Recipe.fromJson(response);
      try {
        await DatabaseService.instance.upsertRecipes([recipe]);
      } catch (_) {}
      return recipe;
    } catch (e) {
      _logger.e('Error fetching recipe details: $e');
      // Try to return from cache
      try {
        final cached = await DatabaseService.instance.getRecipes();
        final found = cached.firstWhere((r) => r.id == id, orElse: () => throw e);
        return found;
      } catch (_) {
        rethrow;
      }
    }
  }

  // Get recommendations
  Future<List<Recipe>> getRecommendations({
    required List<String> selectedFridgeItemIds,
    String? dietaryPreferences,
    int limit = 6,
  }) async {
    try {
      _logger.d('Fetching recipe recommendations');

      final response = await _apiService.post(
        '/api/recommendations',
        data: {
          'selectedFridgeItemIds': selectedFridgeItemIds,
          if (dietaryPreferences != null)
            'dietaryPreferences': dietaryPreferences,
          'limit': limit,
        },
      );

      final recipes = (response['recommendations'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();

      _logger.d('Fetched ${recipes.length} recommendations');
      return recipes;
    } catch (e) {
      _logger.e('Error fetching recommendations: $e');
      rethrow;
    }
  }

  // Generate recipe with AI
  Future<Recipe> generateRecipeWithAI({
    required List<String> ingredients,
    String? dietaryPreferences,
    int? targetCalories,
    int? cookingTimeMinutes,
  }) async {
    try {
      _logger.d('Generating recipe with AI');

      final response = await _apiService.post(
        '/api/ai/generate-recipe',
        data: {
          'ingredients': ingredients,
          if (dietaryPreferences != null)
            'dietaryPreferences': dietaryPreferences,
          if (targetCalories != null) 'targetCalories': targetCalories,
          if (cookingTimeMinutes != null)
            'cookingTimeMinutes': cookingTimeMinutes,
        },
      );

      _logger.d('Recipe generated successfully');
      return Recipe.fromJson(response);
    } catch (e) {
      _logger.e('Error generating recipe: $e');
      rethrow;
    }
  }

  // Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      _logger.d('Searching recipes: $query');

      final response = await _apiService.get(
        '/api/recipes',
        queryParameters: {'search': query},
      );

      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();

      _logger.d('Found ${recipes.length} recipes');
      return recipes;
    } catch (e) {
      _logger.e('Error searching recipes: $e');
      rethrow;
    }
  }
}

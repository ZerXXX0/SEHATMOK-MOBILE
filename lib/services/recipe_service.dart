import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/ai_recipe_model.dart';
import '../models/recipe_model.dart';
import '../models/recommendation_model.dart';
import 'api_service.dart';
import 'database_service.dart';

class RecipeService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  RecipeService(this._apiService);

  // Get all recipes
  Future<List<Recipe>> getRecipes({
    String? query,
    String? category,
  }) async {
    try {
      _logger.d('Fetching recipes');

      final response = await _apiService.get(
        '/api/recipes',
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          if (category != null && category.trim().isNotEmpty)
            'category': category.trim(),
        },
      );

      final recipes = (response as List)
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

  // Get recommendations based on selected fridge items
  Future<RecommendationResponse> getRecommendations({
    required List<String> selectedFridgeItemIds,
    String? dietaryPreferences,
  }) async {
    try {
      _logger.d('Fetching recipe recommendations');

      final response = await _apiService.post(
        '/api/recommendations',
        data: {
          'selectedFridgeItemIds': selectedFridgeItemIds,
          if (dietaryPreferences != null && dietaryPreferences.trim().isNotEmpty)
            'dietaryPreferences': dietaryPreferences.trim(),
        },
      );

      final result = RecommendationResponse.fromJson(response);
      _logger.d('Fetched ${result.recommendations.length} recommendations');
      return result;
    } catch (e) {
      _logger.e('Error fetching recommendations: $e');
      rethrow;
    }
  }

  // Get recommendations using all fridge items
  Future<RecommendationResponse> getFridgeRecommendations() async {
    try {
      _logger.d('Fetching fridge recommendations');

      final response = await _apiService.get('/api/recommendations');
      return RecommendationResponse.fromJson(response);
    } catch (e) {
      _logger.e('Error fetching fridge recommendations: $e');
      rethrow;
    }
  }

  // Generate recipes with AI
  Future<AiRecipeCandidatesResponse> generateRecipesWithAI({
    required List<String> selectedFridgeItemIds,
    String? dietaryPreferences,
  }) async {
    try {
      _logger.d('Generating recipes with AI');

      final response = await _apiService.post(
        '/api/ai/generate-recipes',
        data: {
          'selectedFridgeItemIds': selectedFridgeItemIds,
          if (dietaryPreferences != null && dietaryPreferences.trim().isNotEmpty)
            'dietaryPreferences': dietaryPreferences.trim(),
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      return AiRecipeCandidatesResponse.fromJson(response);
    } catch (e) {
      _logger.e('Error generating recipes with AI: $e');
      rethrow;
    }
  }

  // Save AI recipe to recipes list
  Future<AiRecipeSaveResponse> saveAiRecipe(AiRecipeCandidate recipe) async {
    try {
      _logger.d('Saving AI recipe');

      final response = await _apiService.post(
        '/api/ai/save-recipe',
        data: {
          'recipe': recipe.toSavePayload(),
        },
      );

      return AiRecipeSaveResponse.fromJson(response);
    } catch (e) {
      _logger.e('Error saving AI recipe: $e');
      rethrow;
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(String id) async {
    try {
      _logger.d('Deleting recipe: $id');
      try {
        await _apiService.delete('/api/recipes/$id');
      } catch (e) {
        // Fallback to admin route if user is admin
        await _apiService.delete('/api/admin/recipes/$id');
      }
      try {
        await DatabaseService.instance.deleteRecipe(id);
      } catch (_) {}
    } catch (e) {
      _logger.e('Error deleting recipe: $e');
      rethrow;
    }
  }

  // Search recipes
  Future<List<Recipe>> searchRecipes(String query, {String? category}) async {
    return getRecipes(query: query, category: category);
  }
}

import 'package:logger/logger.dart';

import '../models/recipe_model.dart';
import 'api_service.dart';

class BookmarkResponse {
  final List<String> recipeIds;
  final List<Recipe> recipes;

  const BookmarkResponse({
    required this.recipeIds,
    required this.recipes,
  });

  factory BookmarkResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkResponse(
      recipeIds: (json['recipeIds'] as List? ?? [])
          .map((item) => item as String)
          .toList(),
      recipes: (json['recipes'] as List? ?? [])
          .map((item) => Recipe.fromJson(item))
          .toList(),
    );
  }
}

class BookmarkService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  BookmarkService(this._apiService);

  Future<BookmarkResponse> getBookmarks() async {
    try {
      _logger.d('Fetching bookmarks');
      final response = await _apiService.get('/api/bookmarks');
      return BookmarkResponse.fromJson(response);
    } catch (e) {
      _logger.e('Error fetching bookmarks: $e');
      rethrow;
    }
  }

  Future<String> addBookmark(String recipeId) async {
    try {
      _logger.d('Adding bookmark');
      final response = await _apiService.post(
        '/api/bookmarks',
        data: {'recipeId': recipeId},
      );
      return response['recipeId'] as String;
    } catch (e) {
      _logger.e('Error adding bookmark: $e');
      rethrow;
    }
  }

  Future<String> removeBookmark(String recipeId) async {
    try {
      _logger.d('Removing bookmark');
      final response = await _apiService.delete(
        '/api/bookmarks/$recipeId',
      );
      if (response is Map<String, dynamic> && response['recipeId'] is String) {
        return response['recipeId'] as String;
      }
      return recipeId;
    } catch (e) {
      _logger.e('Error removing bookmark: $e');
      rethrow;
    }
  }
}

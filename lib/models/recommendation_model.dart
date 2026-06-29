import 'recipe_model.dart';

class RecommendationResponse {
  final int? targetCalories;
  final List<SelectedFridgeItem> selectedFridgeItems;
  final String dietaryPreferences;
  final List<Recipe> recommendations;

  const RecommendationResponse({
    required this.targetCalories,
    required this.selectedFridgeItems,
    required this.dietaryPreferences,
    required this.recommendations,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final selected = (json['selectedFridgeItems'] as List? ?? [])
        .map((item) => SelectedFridgeItem.fromJson(item))
        .toList();

    final recipes = (json['recommendations'] as List? ?? [])
        .map((item) => Recipe.fromJson(item))
        .toList();

    return RecommendationResponse(
      targetCalories: (json['targetCalories'] as num?)?.toInt(),
      selectedFridgeItems: selected,
      dietaryPreferences: (json['dietaryPreferences'] as String?) ?? '',
      recommendations: recipes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetCalories': targetCalories,
      'selectedFridgeItems': selectedFridgeItems.map((item) => item.toJson()).toList(),
      'dietaryPreferences': dietaryPreferences,
      'recommendations': recommendations.map((item) => item.toJson()).toList(),
    };
  }
}

class SelectedFridgeItem {
  final String id;
  final String name;
  final String category;

  const SelectedFridgeItem({
    required this.id,
    required this.name,
    required this.category,
  });

  factory SelectedFridgeItem.fromJson(Map<String, dynamic> json) {
    return SelectedFridgeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
    };
  }
}

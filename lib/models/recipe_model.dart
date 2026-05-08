import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class Recipe {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final int? preparationTime;
  final int? cookingTime;
  final int? servings;
  final String? difficulty;
  final NutritionInfo? nutrition;
  final double? matchPercent;
  final double? ingredientScore;
  final double? calorieScore;
  final double? finalScore;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.ingredients,
    required this.instructions,
    this.preparationTime,
    this.cookingTime,
    this.servings,
    this.difficulty,
    this.nutrition,
    this.matchPercent,
    this.ingredientScore,
    this.calorieScore,
    this.finalScore,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  int get totalTime => (preparationTime ?? 0) + (cookingTime ?? 0);
}

@JsonSerializable()
class NutritionInfo {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) =>
      _$NutritionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionInfoToJson(this);
}

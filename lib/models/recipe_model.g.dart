// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  instructions: (json['instructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  preparationTime: (json['preparationTime'] as num?)?.toInt(),
  cookingTime: (json['cookingTime'] as num?)?.toInt(),
  servings: (json['servings'] as num?)?.toInt(),
  difficulty: json['difficulty'] as String?,
  nutrition: json['nutrition'] == null
      ? null
      : NutritionInfo.fromJson(json['nutrition'] as Map<String, dynamic>),
  matchPercent: (json['matchPercent'] as num?)?.toDouble(),
  ingredientScore: (json['ingredientScore'] as num?)?.toDouble(),
  calorieScore: (json['calorieScore'] as num?)?.toDouble(),
  finalScore: (json['finalScore'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'ingredients': instance.ingredients,
  'instructions': instance.instructions,
  'preparationTime': instance.preparationTime,
  'cookingTime': instance.cookingTime,
  'servings': instance.servings,
  'difficulty': instance.difficulty,
  'nutrition': instance.nutrition,
  'matchPercent': instance.matchPercent,
  'ingredientScore': instance.ingredientScore,
  'calorieScore': instance.calorieScore,
  'finalScore': instance.finalScore,
  'createdAt': instance.createdAt.toIso8601String(),
};

NutritionInfo _$NutritionInfoFromJson(Map<String, dynamic> json) =>
    NutritionInfo(
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionInfoToJson(NutritionInfo instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'fiber': instance.fiber,
    };

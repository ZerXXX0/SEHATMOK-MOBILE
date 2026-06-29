import 'recipe_model.dart';

class AiRecipeCandidatesResponse {
  final List<AiRecipeCandidate> candidates;

  const AiRecipeCandidatesResponse({
    required this.candidates,
  });

  factory AiRecipeCandidatesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['candidates'] as List? ?? [])
        .map((item) => AiRecipeCandidate.fromJson(item))
        .toList();

    return AiRecipeCandidatesResponse(candidates: list);
  }

  Map<String, dynamic> toJson() {
    return {
      'candidates': candidates.map((item) => item.toJson()).toList(),
    };
  }
}

class AiRecipeCandidate {
  final String name;
  final String description;
  final int servings;
  final int cookTimeMinutes;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final NutritionInfo nutrition;
  final int matchedIngredientCount;
  final int totalRequiredIngredientCount;
  final int ingredientMatchPercent;
  final List<String> missingIngredients;

  const AiRecipeCandidate({
    required this.name,
    required this.description,
    required this.servings,
    required this.cookTimeMinutes,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    required this.matchedIngredientCount,
    required this.totalRequiredIngredientCount,
    required this.ingredientMatchPercent,
    required this.missingIngredients,
  });

  factory AiRecipeCandidate.fromJson(Map<String, dynamic> json) {
    return AiRecipeCandidate(
      name: json['name'] as String,
      description: json['description'] as String,
      servings: (json['servings'] as num).toInt(),
      cookTimeMinutes: (json['cookTimeMinutes'] as num).toInt(),
      ingredients: (json['ingredients'] as List)
          .map((item) => RecipeIngredient.fromJson(item))
          .toList(),
      steps: (json['steps'] as List).map((item) => item as String).toList(),
      nutrition: NutritionInfo.fromJson(
        json['nutrition'] as Map<String, dynamic>,
      ),
      matchedIngredientCount: (json['matchedIngredientCount'] as num).toInt(),
      totalRequiredIngredientCount:
          (json['totalRequiredIngredientCount'] as num).toInt(),
      ingredientMatchPercent: (json['ingredientMatchPercent'] as num).toInt(),
      missingIngredients: (json['missingIngredients'] as List)
          .map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'servings': servings,
      'cookTimeMinutes': cookTimeMinutes,
      'ingredients': ingredients.map((item) => item.toJson()).toList(),
      'steps': steps,
      'nutrition': nutrition.toJson(),
      'matchedIngredientCount': matchedIngredientCount,
      'totalRequiredIngredientCount': totalRequiredIngredientCount,
      'ingredientMatchPercent': ingredientMatchPercent,
      'missingIngredients': missingIngredients,
    };
  }

  Map<String, dynamic> toSavePayload() {
    return {
      'name': name,
      'description': description.trim().isEmpty ? 'AI Generated Gourmet Recipe.' : description,
      'servings': servings,
      'cookTimeMinutes': cookTimeMinutes,
      'ingredients': ingredients.map((item) => item.toJson()).toList(),
      'steps': steps,
      'nutrition': nutrition.toJson(),
    };
  }
}

class AiRecipeSaveResponse {
  final String recipeId;
  final bool reused;

  const AiRecipeSaveResponse({
    required this.recipeId,
    required this.reused,
  });

  factory AiRecipeSaveResponse.fromJson(Map<String, dynamic> json) {
    return AiRecipeSaveResponse(
      recipeId: json['recipeId'] as String,
      reused: json['reused'] as bool,
    );
  }
}

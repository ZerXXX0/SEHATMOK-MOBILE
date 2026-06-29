class Recipe {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final int? servings;
  final int? cookTimeMinutes;
  final List<RecipeIngredient>? ingredients;
  final List<String>? steps;
  final int? matchedIngredientCount;
  final int? totalRequiredIngredientCount;
  final int? ingredientAvailabilityPercent;
  final List<String>? missingIngredients;
  final int? matchPercent;
  final double? ingredientScore;
  final double? calorieScore;
  final double? finalScore;
  final String? explanation;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.servings,
    this.cookTimeMinutes,
    this.ingredients,
    this.steps,
    this.matchedIngredientCount,
    this.totalRequiredIngredientCount,
    this.ingredientAvailabilityPercent,
    this.missingIngredients,
    this.matchPercent,
    this.ingredientScore,
    this.calorieScore,
    this.finalScore,
    this.explanation,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final nutrition = json['nutrition'] as Map<String, dynamic>?;
    final ingredientsRaw = json['ingredients'] as List?;
    final stepsRaw = (json['steps'] ?? json['instructions']) as List?;

    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      calories: (json['calories'] as num?)?.toInt() ??
        (nutrition?['calories'] as num?)?.toInt(),
      protein: (json['protein'] as num?)?.toDouble() ??
        (nutrition?['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble() ??
        (nutrition?['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble() ??
        (nutrition?['fat'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ??
        (nutrition?['fiber'] as num?)?.toDouble(),
      servings: (json['servings'] as num?)?.toInt(),
      cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ??
        (json['cookingTime'] as num?)?.toInt(),
      ingredients: ingredientsRaw
        ?.map((item) {
        if (item is Map<String, dynamic>) {
          return RecipeIngredient.fromJson(item);
        }
        if (item is String) {
          return RecipeIngredient(name: item);
        }
        return null;
        })
        .whereType<RecipeIngredient>()
        .toList(),
      steps: stepsRaw?.map((item) => item as String).toList(),
      matchedIngredientCount:
          (json['matchedIngredientCount'] as num?)?.toInt(),
      totalRequiredIngredientCount:
          (json['totalRequiredIngredientCount'] as num?)?.toInt(),
      ingredientAvailabilityPercent:
          (json['ingredientAvailabilityPercent'] as num?)?.toInt(),
      missingIngredients: (json['missingIngredients'] as List?)
          ?.map((item) => item as String)
          .toList(),
      matchPercent: (json['matchPercent'] as num?)?.toInt(),
      ingredientScore: (json['ingredientScore'] as num?)?.toDouble(),
      calorieScore: (json['calorieScore'] as num?)?.toDouble(),
      finalScore: (json['finalScore'] as num?)?.toDouble(),
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'servings': servings,
      'cookTimeMinutes': cookTimeMinutes,
      'ingredients': ingredients?.map((item) => item.toJson()).toList(),
      'steps': steps,
      'matchedIngredientCount': matchedIngredientCount,
      'totalRequiredIngredientCount': totalRequiredIngredientCount,
      'ingredientAvailabilityPercent': ingredientAvailabilityPercent,
      'missingIngredients': missingIngredients,
      'matchPercent': matchPercent,
      'ingredientScore': ingredientScore,
      'calorieScore': calorieScore,
      'finalScore': finalScore,
      'explanation': explanation,
    };
  }
}

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

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories >= 0 ? calories : 0,
      'protein': protein >= 0 ? protein : 0.0,
      'carbs': carbs >= 0 ? carbs : 0.0,
      'fat': fat >= 0 ? fat : 0.0,
      'fiber': fiber >= 0 ? fiber : 0.0,
    };
  }
}

class RecipeIngredient {
  final String name;
  final double? quantity;
  final String? unit;

  const RecipeIngredient({
    required this.name,
    this.quantity,
    this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'quantity': (quantity != null && quantity! > 0) ? quantity : 1.0,
      'unit': (unit != null && unit!.trim().isNotEmpty) ? unit!.trim() : 'pcs',
    };
  }
}

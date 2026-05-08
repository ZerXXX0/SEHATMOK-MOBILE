import 'package:json_annotation/json_annotation.dart';

part 'meal_plan_model.g.dart';

@JsonSerializable()
class MealPlan {
  final String id;
  final String userId;
  final DateTime date;
  final MealSlot? breakfast;
  final MealSlot? lunch;
  final MealSlot? dinner;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MealPlan({
    required this.id,
    required this.userId,
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
    required this.createdAt,
    this.updatedAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);
  Map<String, dynamic> toJson() => _$MealPlanToJson(this);
}

@JsonSerializable()
class MealSlot {
  final String recipeId;
  final String recipeName;
  final String? recipeImageUrl;
  final int? calories;
  final DateTime createdAt;

  MealSlot({
    required this.recipeId,
    required this.recipeName,
    this.recipeImageUrl,
    this.calories,
    required this.createdAt,
  });

  factory MealSlot.fromJson(Map<String, dynamic> json) =>
      _$MealSlotFromJson(json);
  Map<String, dynamic> toJson() => _$MealSlotToJson(this);
}

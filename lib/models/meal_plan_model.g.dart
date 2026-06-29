// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => MealPlan(
  id: json['id'] as String,
  userId: json['userId'] as String,
  date: DateTime.parse(json['date'] as String),
  breakfast: json['breakfast'] == null
      ? null
      : MealSlot.fromJson(json['breakfast'] as Map<String, dynamic>),
  lunch: json['lunch'] == null
      ? null
      : MealSlot.fromJson(json['lunch'] as Map<String, dynamic>),
  dinner: json['dinner'] == null
      ? null
      : MealSlot.fromJson(json['dinner'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MealPlanToJson(MealPlan instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'date': instance.date.toIso8601String(),
  'breakfast': instance.breakfast,
  'lunch': instance.lunch,
  'dinner': instance.dinner,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

MealSlot _$MealSlotFromJson(Map<String, dynamic> json) => MealSlot(
  recipeId: json['recipeId'] as String,
  recipeName: json['recipeName'] as String,
  recipeImageUrl: json['recipeImageUrl'] as String?,
  calories: (json['calories'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MealSlotToJson(MealSlot instance) => <String, dynamic>{
  'recipeId': instance.recipeId,
  'recipeName': instance.recipeName,
  'recipeImageUrl': instance.recipeImageUrl,
  'calories': instance.calories,
  'createdAt': instance.createdAt.toIso8601String(),
};

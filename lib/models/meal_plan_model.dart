import 'recipe_model.dart';

class MealPlanDay {
  final String date;
  final List<MealPlanItem> items;

  const MealPlanDay({
    required this.date,
    required this.items,
  });

  factory MealPlanDay.fromJson(Map<String, dynamic> json) {
    return MealPlanDay(
      date: json['date'] as String,
      items: (json['items'] as List? ?? [])
          .map((item) => MealPlanItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class MealPlanItem {
  final String id;
  final String slot;
  final Recipe? recipe;

  const MealPlanItem({
    required this.id,
    required this.slot,
    required this.recipe,
  });

  factory MealPlanItem.fromJson(Map<String, dynamic> json) {
    return MealPlanItem(
      id: json['id'] as String,
      slot: json['slot'] as String,
      recipe: json['recipe'] == null
          ? null
          : Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slot': slot,
      'recipe': recipe?.toJson(),
    };
  }
}

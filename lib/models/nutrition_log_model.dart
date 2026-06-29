class NutritionLog {
  final String id;
  final String userId;
  final String type;
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final DateTime createdAt;

  const NutritionLog({
    required this.id,
    required this.userId,
    required this.type,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    required this.createdAt,
  });

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

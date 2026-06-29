import 'hydration_model.dart';

class DashboardSummary {
  final int targetCalories;
  final int totalIntakeToday;
  final int totalOuttakeToday;
  final int remainingCalories;
  final MacroTargets macroTargets;
  final MacroCurrent macroCurrent;
  final int caloriesCurrent;
  final DashboardUser user;
  final List<NearExpiryItem> nearExpiryItems;
  final int nearExpiryCount;
  final int expiredCount;
  final List<String> mealPlanMissingSlots;
  final int fridgeItemCount;
  final int activeGroceryCount;
  final HydrationSummary hydration;

  const DashboardSummary({
    required this.targetCalories,
    required this.totalIntakeToday,
    required this.totalOuttakeToday,
    required this.remainingCalories,
    required this.macroTargets,
    required this.macroCurrent,
    required this.caloriesCurrent,
    required this.user,
    required this.nearExpiryItems,
    required this.nearExpiryCount,
    required this.expiredCount,
    required this.mealPlanMissingSlots,
    required this.fridgeItemCount,
    required this.activeGroceryCount,
    required this.hydration,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      targetCalories: (json['targetCalories'] as num).toInt(),
      totalIntakeToday: (json['totalIntakeToday'] as num).toInt(),
      totalOuttakeToday: (json['totalOuttakeToday'] as num).toInt(),
      remainingCalories: (json['remainingCalories'] as num).toInt(),
      macroTargets:
          MacroTargets.fromJson(json['macroTargets'] as Map<String, dynamic>),
      macroCurrent:
          MacroCurrent.fromJson(json['macroCurrent'] as Map<String, dynamic>),
      caloriesCurrent: (json['caloriesCurrent'] as num).toInt(),
      user: DashboardUser.fromJson(json['user'] as Map<String, dynamic>),
      nearExpiryItems: (json['nearExpiryItems'] as List? ?? [])
          .map((item) => NearExpiryItem.fromJson(item))
          .toList(),
      nearExpiryCount: (json['nearExpiryCount'] as num).toInt(),
      expiredCount: (json['expiredCount'] as num).toInt(),
      mealPlanMissingSlots: (json['mealPlanMissingSlots'] as List? ?? [])
          .map((item) => item as String)
          .toList(),
      fridgeItemCount: (json['fridgeItemCount'] as num).toInt(),
      activeGroceryCount: (json['activeGroceryCount'] as num).toInt(),
      hydration:
          HydrationSummary.fromJson(json['hydration'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetCalories': targetCalories,
      'totalIntakeToday': totalIntakeToday,
      'totalOuttakeToday': totalOuttakeToday,
      'remainingCalories': remainingCalories,
      'macroTargets': macroTargets.toJson(),
      'macroCurrent': macroCurrent.toJson(),
      'caloriesCurrent': caloriesCurrent,
      'user': user.toJson(),
      'nearExpiryItems': nearExpiryItems.map((item) => item.toJson()).toList(),
      'nearExpiryCount': nearExpiryCount,
      'expiredCount': expiredCount,
      'mealPlanMissingSlots': mealPlanMissingSlots,
      'fridgeItemCount': fridgeItemCount,
      'activeGroceryCount': activeGroceryCount,
      'hydration': hydration.toJson(),
    };
  }
}

class MacroTargets {
  final int proteinG;
  final int carbsG;
  final int fatsG;

  const MacroTargets({
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
  });

  factory MacroTargets.fromJson(Map<String, dynamic> json) {
    return MacroTargets(
      proteinG: (json['proteinG'] as num).toInt(),
      carbsG: (json['carbsG'] as num).toInt(),
      fatsG: (json['fatsG'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatsG': fatsG,
    };
  }
}

class MacroCurrent {
  final int proteinG;
  final int carbsG;
  final int fatsG;

  const MacroCurrent({
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
  });

  factory MacroCurrent.fromJson(Map<String, dynamic> json) {
    return MacroCurrent(
      proteinG: (json['proteinG'] as num).toInt(),
      carbsG: (json['carbsG'] as num).toInt(),
      fatsG: (json['fatsG'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatsG': fatsG,
    };
  }
}

class DashboardUser {
  final String? name;
  final String email;
  final String? avatarUrl;

  const DashboardUser({
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      name: json['name'] as String?,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}

class NearExpiryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final String expiryDate;
  final String expiryLabel;

  const NearExpiryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.expiryLabel,
  });

  factory NearExpiryItem.fromJson(Map<String, dynamic> json) {
    return NearExpiryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      expiryDate: json['expiryDate'] as String,
      expiryLabel: json['expiryLabel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate,
      'expiryLabel': expiryLabel,
    };
  }
}

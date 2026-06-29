class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String? role;
  final int? age;
  final double? weight;
  final double? height;
  final String? activityLevel;
  final int? targetCalories;
  final int? bmr;
  final int? tdee;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.role,
    this.age,
    this.weight,
    this.height,
    this.activityLevel,
    this.targetCalories,
    this.bmr,
    this.tdee,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String?,
      age: (json['age'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] as String?,
      targetCalories: (json['targetCalories'] as num?)?.toInt(),
      bmr: (json['bmr'] as num?)?.toInt(),
      tdee: (json['tdee'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'age': age,
      'weight': weight,
      'height': height,
      'activityLevel': activityLevel,
      'targetCalories': targetCalories,
      'bmr': bmr,
      'tdee': tdee,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? role,
    int? age,
    double? weight,
    double? height,
    String? activityLevel,
    int? targetCalories,
    int? bmr,
    int? tdee,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      activityLevel: activityLevel ?? this.activityLevel,
      targetCalories: targetCalories ?? this.targetCalories,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
    );
  }
}

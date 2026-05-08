import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String role;
  final String status;
  final int? age;
  final double? weight;
  final double? height;
  final String? activityLevel;
  final int? targetCalories;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.role,
    required this.status,
    this.age,
    this.weight,
    this.height,
    this.activityLevel,
    this.targetCalories,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? role,
    String? status,
    int? age,
    double? weight,
    double? height,
    String? activityLevel,
    int? targetCalories,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      activityLevel: activityLevel ?? this.activityLevel,
      targetCalories: targetCalories ?? this.targetCalories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

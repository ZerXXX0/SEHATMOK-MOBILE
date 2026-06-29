// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  role: json['role'] as String,
  status: json['status'] as String,
  age: (json['age'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  activityLevel: json['activityLevel'] as String?,
  targetCalories: (json['targetCalories'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'role': instance.role,
  'status': instance.status,
  'age': instance.age,
  'weight': instance.weight,
  'height': instance.height,
  'activityLevel': instance.activityLevel,
  'targetCalories': instance.targetCalories,
  'createdAt': instance.createdAt.toIso8601String(),
};

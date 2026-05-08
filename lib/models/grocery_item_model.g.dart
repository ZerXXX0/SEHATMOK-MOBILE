// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroceryItem _$GroceryItemFromJson(Map<String, dynamic> json) => GroceryItem(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
  isDone: json['isDone'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GroceryItemToJson(GroceryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'isDone': instance.isDone,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

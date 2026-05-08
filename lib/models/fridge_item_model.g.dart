// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FridgeItem _$FridgeItemFromJson(Map<String, dynamic> json) => FridgeItem(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  unit: json['unit'] as String,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$FridgeItemToJson(FridgeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'category': instance.category,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

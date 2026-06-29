import 'package:json_annotation/json_annotation.dart';

part 'grocery_item_model.g.dart';

@JsonSerializable()
class GroceryItem {
  final String id;
  final String userId;
  final String name;
  final double? quantity;
  final String? unit;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroceryItem({
    required this.id,
    required this.userId,
    required this.name,
    this.quantity,
    this.unit,
    required this.isDone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) =>
      _$GroceryItemFromJson(json);
  Map<String, dynamic> toJson() => _$GroceryItemToJson(this);

  GroceryItem copyWith({
    String? id,
    String? userId,
    String? name,
    double? quantity,
    String? unit,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

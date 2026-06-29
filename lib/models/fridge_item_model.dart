import 'package:json_annotation/json_annotation.dart';

part 'fridge_item_model.g.dart';

@JsonSerializable()
class FridgeItem {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime createdAt;

  FridgeItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.createdAt,
  });

  factory FridgeItem.fromJson(Map<String, dynamic> json) =>
      _$FridgeItemFromJson(json);
  Map<String, dynamic> toJson() => _$FridgeItemToJson(this);

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final difference = expiryDate!.difference(DateTime.now());
    return difference.inHours > 0 && difference.inHours <= 48;
  }

  Duration? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now());
  }
}
